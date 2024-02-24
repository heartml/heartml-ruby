# frozen_string_literal: true

require_relative "heartml/version"

require "nokolexbor"
require "concurrent"
require "json"

# Include this module into your own component class
module Heartml
  class Error < StandardError; end

  module JSTemplateLiterals
    refine Kernel do
      def `(str)
        str
      end
    end
  end

  using JSTemplateLiterals

  AttributeBinding = Struct.new(:matcher, :method_name, :method, :only_for_tag, keyword_init: true) # rubocop:disable Lint/StructNewOverride

  require_relative "heartml/fragment"
  require_relative "heartml/query_selection"
  require "heartml/server_effects"

  include ServerEffects

  def self.registered_elements
    @registered_elements ||= Concurrent::Set.new

    @registered_elements.each do |component|
      begin
        next if Kernel.const_get(component.to_s) == component # thin out unloaded consts
      rescue NameError; end # rubocop:disable Lint/SuppressedException

      @registered_elements.delete component
    end

    @registered_elements
  end

  def self.register_element(component)
    @registered_elements ||= Concurrent::Set.new
    @registered_elements << component
  end

  # @param klass [Class]
  # @return [void]
  def self.included(klass)
    klass.extend ClassMethods

    klass.attribute_binding "server-children", :_server_children, only: :template
    klass.attribute_binding "server-content", :_server_content, only: :template
    klass.attribute_binding "server-unsafe-eval", :_server_unsafe_eval

    # Don't stomp on a superclass's `content` method
    has_content_method = begin
      klass.instance_method(:content)
    rescue NameError
      false
    end

    klass.include ContentMethod unless has_content_method

    ServerEffects.included_extras(klass)
  end

  # Extends the component class
  module ClassMethods
    def camelcased(method_symbols)
      Array(method_symbols).each do |method_symbol|
        alias_method(method_symbol.to_s.gsub(/(?!^)_[a-z0-9]/) { |match| match[1].upcase }, method_symbol)
      end
    end

    def html_file_extensions = %w[module.html mod.html heartml].freeze

    def processed_css_extension = "css-local"

    # @param tag_name [String]
    # @param heart_module [String] if not provided, a class method called `source_location` must be
    #   available with the absolute path of the Ruby file
    # @param shadow_root [Boolean] default is true
    # @return [void]
    def define(tag_name, heart_module = nil, shadow_root: true) # rubocop:disable Metrics/AbcSize
      if heart_module.nil? && !respond_to?(:source_location)
        raise Heartml::Error, "You must either supply a file path argument or respond to `source_location'"
      end

      self.tag_name tag_name

      if heart_module
        self.heart_module heart_module
      else
        basepath = File.join(File.dirname(source_location), File.basename(source_location, ".*"))

        self.heart_module(html_file_extensions.lazy.filter_map do |ext|
          path = "#{basepath}.#{ext}"
          File.exist?(path) ? path : nil
        end.first)

        raise Heartml::Error, "Cannot find sidecar HTML module for `#{self}'" unless @heart_module
      end

      self.shadow_root shadow_root
    end

    # @param value [String]
    # @return [String]
    def tag_name(value = nil)
      @tag_name ||= begin
        Heartml.register_element self
        value
      end
    end

    def output_tag_name(value = nil) = @output_tag_name ||= value

    # @param value [String]
    # @return [String]
    def heart_module(value = nil) = @heart_module ||= value

    # @param value [Boolean]
    # @return [Boolean]
    def shadow_root(value = nil) = @shadow_root ||= value

    # @return [Nokolexbor::Element]
    def doc
      @doc ||= begin
        @doc_html = "<#{tag_name}>#{File.read(heart_module).strip}</#{tag_name}>"
        Nokolexbor::DocumentFragment.parse(@doc_html).first_element_child
      end
    end

    # @return [String]
    def doc_html = @doc_html

    def attribute_bindings = @attribute_bindings ||= []

    def attribute_binding(matcher, method_name, only: nil)
      attribute_bindings << AttributeBinding.new(
        matcher: Regexp.new(matcher),
        method_name:,
        only_for_tag: only
      )
    end
  end

  module ContentMethod
    # @return [String, Nokolexbor::Element]
    def content = @_content
  end

  def replaced_content=(new_content)
    @_replaced_content = new_content
  end

  def context
    return @context if @context

    return unless respond_to?(:view_context)

    view_context # compatibility with other Ruby component systems
  end

  # Override in component
  #
  # @return [Hash]
  def attributes = {}

  def rendering_mode = @_rendering_mode || :node

  def rendering_mode=(mode)
    @_rendering_mode = case mode
                       when :node, :string
                         mode
                       end
  end

  # @param attributes [Hash]
  # @param content [String, Nokolexbor::Element]
  def render_element(attributes: self.attributes, content: self.content, context: self.context) # rubocop:disable Metrics
    doc = self.class.doc.clone
    @doc_html ||= self.class.doc_html # keep a spare copy for determining error line number
    @_content = content
    @context = context

    tmpl_el = doc.css("> template").find do |node|
      node.attributes.empty? ||
        (node.attributes.count == 1 && node.attributes.any? { |k| k[0].start_with?("data-") })
    end

    unless tmpl_el
      tmpl_el = doc.document.create_element("template")
      immediate_children = doc.css("> :not(style):not(script)")
      tmpl_el.children[0] << immediate_children
      doc.prepend_child(tmpl_el)
    end

    # Process all the template bits
    process_fragment(tmpl_el)

    # Set attributes on the custom element
    attributes.each { |k, v| doc[k.to_s.tr("_", "-")] = value_to_attribute(v) if v }

    # Look for external and internal styles
    output_styles = ""
    external_styles = doc.css("link[rel=stylesheet]")
    external_styles.each do |external_style|
      next unless external_style["server-process"]

      output_styles += File.read(File.expand_path(external_style["href"], File.dirname(self.class.heart_module)))
      external_style.remove
    rescue StandardError => e
      raise e.class, e.message.lines.first,
            ["#{self.class.heart_module}:#{external_style.line}", *e.backtrace]
    end
    sidecar_file = "#{File.join(
      File.dirname(self.class.heart_module), File.basename(self.class.heart_module, ".*")
    )}.#{self.class.processed_css_extension}"
    output_styles += if File.exist?(sidecar_file)
                       File.read(sidecar_file)
                     else
                       doc.css("> style:not([scope])").map(&:content).join
                     end

    # Now remove all nodes *except* the template
    doc.children.each do |node|
      node.remove unless node == tmpl_el
    end

    style_tag = nil
    if output_styles.length.positive?
      # We'll transfer everything over to a single style element
      style_tag = tmpl_el.document.create_element("style")
      style_tag.content = output_styles
    end

    child_content = @_replaced_content || content
    if self.class.shadow_root
      # Guess what? We can reuse the same template tag! =)
      tmpl_el["shadowrootmode"] = "open"
      tmpl_el.children[0] << style_tag if style_tag
      doc << child_content if child_content
    else
      tmpl_el.children[0] << style_tag if style_tag
      tmpl_el.children[0].at_css("slot:not([name])")&.swap(child_content) if child_content
      tmpl_el.children[0].children.each do |node|
        doc << node
      end
      tmpl_el.remove
    end

    if self.class.output_tag_name
      swap_doc = doc.document.create_element(self.class.output_tag_name)
      doc.attrs.each do |attr, value|
        swap_doc[attr] = value
      end
      swap_doc << doc.children

      rendering_mode == :node ? swap_doc : swap_doc.to_html
    else
      rendering_mode == :node ? doc : doc.to_html
    end
  end

  def call(...) = render_element(...)

  def inspect = "#<#{self.class.name} #{attributes}>"

  def value_to_attribute(val)
    case val
    when String
      val
    when TrueClass
      ""
    else
      val.to_json
    end
  end

  def node_or_string(val)
    val.is_a?(Nokolexbor::Node) ? val : val.to_s
  end

  # Override in component if need be, otherwise we'll use the node walker/binding pipeline
  #
  # @param fragment [Nokolexbor::Element]
  # @return [void]
  def process_fragment(fragment) = Fragment.new(fragment, self).process

  def process_list(attribute:, node:, item_node:, for_in:) # rubocop:disable Metrics
    _context_nodes.push(node)

    lh = for_in[0].strip.delete_prefix("(").delete_suffix(")").split(",").map!(&:strip)
    rh = for_in[1].strip

    list_items = evaluate_attribute_expression(attribute, rh)

    # TODO: handle object style
    # https://vuejs.org/guide/essentials/list.html#v-for-with-an-object

    return unless list_items

    _in_context_nodes do |previous_context|
      list_items.each_with_index do |list_item, index|
        new_node = item_node.clone
        node.parent << new_node
        new_node["server-added"] = ""

        @_context_locals = { **(previous_context || {}) }
        _context_locals[lh[0]] = list_item
        _context_locals[lh[1]] = index if lh[1]

        Fragment.new(new_node, self).process
      end
    end
  end

  def evaluate_attribute_expression(attribute, eval_code = attribute.value)
    eval_code = eval_code.gsub(/\${(.*)}/, "\#{\\1}")
    _context_locals.keys.reverse_each do |name|
      eval_code = "#{name} = _context_locals[\"#{name}\"];" + eval_code
    end
    instance_eval(eval_code, self.class.heart_module, _line_number_of_node(attribute))
  end

  def class_list_for(obj)
    case obj
    when Hash
      obj.filter { |_k, v| v }.keys
    when Array
      # TODO: handle objects inside of an array?
      obj
    else
      [obj]
    end.join(" ")
  end

  def _line_number_of_node(node)
    loc = node.source_location
    instance_variable_get(:@doc_html)[0..loc].count("\n") + 1
  end

  def _context_nodes = @_context_nodes ||= []

  def _context_locals = @_context_locals ||= {}

  def _check_stack(node)
    node_and_ancestors = [node, *node.ancestors.to_a]
    stack_misses = 0

    _context_nodes.each do |stack_node|
      if node_and_ancestors.none? { _1["server-added"] } && node_and_ancestors.none? { _1 == stack_node }
        stack_misses += 1
      end
    end

    stack_misses.times { _context_nodes.pop }

    node_and_ancestors.any? { _context_nodes.include?(_1) }
  end

  def _in_context_nodes
    previous_context = _context_locals
    yield previous_context
    @_context_locals = previous_context
  end

  def _server_children(attribute:, node:) # rubocop:disable Lint/UnusedMethodArgument
    self.replaced_content = node.children[0]
    node.remove
  end

  def _server_unsafe_eval(attribute:, node:)
    node_name = node.name
    correct_node = node_name == "template" ? node.children[0] : node
    result = node_or_string(evaluate_attribute_expression(attribute, correct_node.inner_html))

    if node_name == "template"
      node.swap(result)
    else
      node.inner_html = result
      attribute.parent.delete(attribute.name)
    end
  end

  def _server_content(attribute:, node:)
    result = evaluate_attribute_expression(attribute, "content")
    node.swap(result)
  end
end

require_relative "heartml/template_renderer"
require_relative "heartml/bridgetown_renderer" if defined?(Bridgetown)
require_relative "heartml/railtie" if defined?(Rails::Railtie)
