# frozen_string_literal: true

require "heartml"

module Heartml
  module Petite
    # @param klass [Class]
    # @return [void]
    def self.included(klass)
      klass.attribute_binding "v-for", :_petite_for_binding, only: :template
      klass.attribute_binding "v-text", :_petite_text_binding
      klass.attribute_binding "v-html", :_petite_html_binding
      klass.attribute_binding "v-bind", :_petite_bound_attribute
      klass.attribute_binding %r{^:}, :_petite_bound_attribute
    end

    protected

    def _petite_for_binding(attribute:, node:)
      delimiter = node["v-for"].include?(" of ") ? " of " : " in "
      expression = node["v-for"].split(delimiter)

      process_list(
        attribute:,
        node:,
        item_node: node.children[0].first_element_child,
        for_in: expression
      )
    end

    def _petite_text_binding(attribute:, node:)
      node.content = evaluate_attribute_expression(attribute).to_s
    end

    def _petite_html_binding(attribute:, node:)
      node.inner_html = evaluate_attribute_expression(attribute).to_s
    end

    def _petite_bound_attribute(attribute:, node:) # rubocop:disable Metrics
      return if attribute.name == ":key"

      real_attribute = if attribute.name.start_with?(":")
                         attribute.name.delete_prefix(":")
                       elsif attribute.name.start_with?("v-bind:")
                         attribute.name.delete_prefix("v-bind:")
                       end

      obj = evaluate_attribute_expression(attribute)

      if real_attribute == "class"
        node[real_attribute] = class_list_for(obj)
      elsif real_attribute != "style" # style bindings aren't SSRed
        node[real_attribute] = obj if obj
      end
    end
  end
end
