# frozen_string_literal: true

module Heartml
  class Fragment
    def initialize(fragment, component)
      @fragment = fragment
      @component = component
      @attribute_bindings = component.class.attribute_bindings.each do |attr_def|
        attr_def.method = component.method(attr_def.method_name)
      end
    end

    # NOTE: for some reason, the traverse method yields node children first, then the
    # parent node. That doesn't work for our case. We want to go strictly in source order.
    # So this is our own implementation of that.
    def traverse(node, &block)
      yield(node)
      node.children.each { |child| traverse(child, &block) }
    end

    def process(fragment = @fragment) # rubocop:disable Metrics
      traverse(fragment) do |node| # rubocop:disable Metrics/BlockLength
        process_attribute_bindings(node)

        component = Heartml.registered_elements.find { _1.tag_name == node.name }
        if component
          attrs = node.attributes.dup

          new_attrs = {}
          attrs.each do |k, attr|
            unless k == "server-args"
              new_attrs[k] = attr.value
              next
            end
            v = attr.value

            params = v.split(";").map(&:strip)

            params.each do |param|
              new_key, v2 = param.split(":").map(&:strip)
              new_attrs[new_key] = @component.evaluate_attribute_expression(attr, v2)
            end
            attrs.delete(k)
          end
          attrs.merge!(new_attrs)
          attrs.reject! { |k| k.start_with?("server-") || k.start_with?("iso-") || k.start_with?("host-") }
          attrs.transform_keys!(&:to_sym)

          obj = component.new(**attrs)
          render_output = if obj.respond_to?(:render_in)
                            obj.render_in(@component.context, rendering_mode: :node) do
                              process(fragamatize(node.children))
                            end
                          else
                            obj.render_element(
                              content: process(fragamatize(node.children)), context: @component.context
                            )
                          end

          node.replace(render_output)
        end
      end

      fragment
    end

    def fragamatize(node_set)
      frag = Nokolexbor::DocumentFragment.new(@fragment.document)
      node_set.each { |child| child.parent = frag }
      frag
    end

    def process_attribute_bindings(node) # rubocop:todo Metrics
      node.attributes.each do |name, attr_node|
        @attribute_bindings.each do |attribute_binding|
          next if attribute_binding.only_for_tag && node.name != attribute_binding.only_for_tag.to_s
          next unless attribute_binding.matcher.match?(name)
          next if attribute_binding.method.receiver._check_stack(node)

          break unless attribute_binding.method.(attribute: attr_node, node: node)
        end
      rescue Exception => e # rubocop:disable Lint/RescueException
        line_segments = [@component.class.heart_module, @component.class.line_number_of_node(attr_node)]
        raise e.class, e.message.lines.first, [line_segments.join(":"), *e.backtrace]
      end
    end
  end
end
