# frozen_string_literal: true

module Heartml
  module ServerEffects
    # rubocop:disable Naming/MethodName
    module JSPropertyAliases
      def textContent=(value)
        self.content = value
      end

      def innerHTML=(value)
        self.inner_html = value
      end

      def method_missing(meth, *args, **kwargs) # rubocop:disable Style/MissingRespondToMissing
        return super unless meth.to_s.end_with?("=")

        kebob_cased = meth.to_s
                          .gsub(/([A-Z]+)([A-Z][a-z])/, '\1-\2')
                          .gsub(/([a-z\d])([A-Z])/, '\1-\2')
                          .downcase

        self[kebob_cased.delete_suffix("=")] = args[0]
      end
    end
    # rubocop:enable Naming/MethodName

    Nokolexbor::Element.include JSPropertyAliases unless Nokolexbor::Element.instance_methods.include?(:textContent=)

    module ClassMethods
      def directive(name, &block)
        @directives ||= {}
        @directives[name.to_s] = block
      end
    end

    # @param klass [Class]
    # @return [void]
    def self.included(klass) # rubocop:disable Metrics
      klass.attribute_binding "server-effect", :_server_effect_binding
      klass.attribute_binding "iso-effect", :_iso_effect_binding

      klass.singleton_class.attr_reader :directives

      klass.extend ClassMethods

      klass.class_eval do
        directive :show do |_, element, value|
          element["hidden"] = "" unless value
        end

        directive :hide do |_, element, value|
          element["hidden"] = "" if value
        end

        directive :classMap do |_, element, obj|
          obj.each do |k, v|
            element.add_class k.to_s if v
          end
        end
      end
    end

    def _server_effect_binding(attribute:, node:)
      _iso_effect_binding(attribute: attribute, node: node)
      node.remove_attribute "host-effect"
    end

    def _iso_effect_binding(attribute:, node:) # rubocop:disable Metrics
      syntax = attribute.value
      statements = syntax.split(";").map(&:strip)

      statements.each do |statement| # rubocop:disable Metrics
        if statement.start_with?("@")
          # property assignment
          expression = statement.split("=").map(&:strip)
          expression[0] = expression[0][1..]

          value = send(expression[1][1..])

          node.send("#{expression[0]}=", value_to_attribute(value))
        elsif statement.start_with?("$")
          # directive
          directive_name, args_str = statement.strip.match(/(.*)\((.*)\)/).captures
          arg_strs = args_str.split(",").map(&:strip)
          arg_strs.unshift("@")

          if self.class.directives[directive_name.strip[1..]]
            args = arg_strs.map do |arg_str|
              next node if arg_str == "@"

              next arg_str[1...-1] if arg_str.start_with?("'") # string literal

              send(arg_str[1..])
            end

            self.class.directives[directive_name.strip[1..]]&.(self, *args)
          end
        else
          # method call
          method_name, args_str = statement.strip.match(/(.*)\((.*)\)/).captures
          arg_strs = args_str.split(",").map(&:strip)
          arg_strs.unshift("@")

          args = arg_strs.map do |arg_str|
            next node if arg_str == "@"

            next arg_str[1...-1] if arg_str.start_with?("'") # string literal

            send(arg_str[1..])
          end

          send(method_name.strip, *args)
        end

        attribute.name = "host-effect"
      end
    end
  end
end
