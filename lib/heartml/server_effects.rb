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
      def directive(name, function)
        @directives ||= {}
        @directives[name.to_s] = function
      end
    end

    # @param klass [Class]
    # @return [void]
    def self.included_extras(klass) # rubocop:disable Metrics
      klass.attribute_binding "server-effect", :_server_effect_binding
      klass.attribute_binding "iso-effect", :_iso_effect_binding

      klass.singleton_class.attr_reader :directives

      klass.extend ClassMethods

      klass.class_eval do
        directive :show, ->(_, node, value) { node["hidden"] = "" unless value }

        directive :hide, ->(_, node, value) { node["hidden"] = "" if value }

        directive :classMap, ->(_, node, obj) {
          obj.each do |k, v|
            node.add_class k.to_s if v
          end
        }

        directive :attribute, ->(_, node, name, value) {
          node[name] = value if name.match?(%r{^aria[A-Z-]}) || value
        }
      end
    end

    def _server_effect_binding(attribute:, node:)
      _iso_effect_binding(attribute:, node:)
      node.remove_attribute "host-lazy-effect"
    end

    def _iso_effect_binding(attribute:, node:) # rubocop:disable Metrics
      syntax = attribute.value
      statements = syntax.split(";").map(&:strip)

      statements.each do |statement| # rubocop:disable Metrics
        if statement.start_with?(".")
          # shortcut for text content
          statement = "@textContent=#{statement}"
        end

        if statement.start_with?("@")
          # property assignment
          expression = statement.split("=").map(&:strip)
          expression[0] = expression[0][1..]

          value = send(expression[1][1..])
          attribute_value = if expression[0].match?(%r{^aria[A-Z-]}) && [true, false].include?(value)
                              value
                            else
                              value_to_attribute(value)
                            end

          node.send("#{expression[0]}=", attribute_value) unless attribute_value.nil?
        elsif statement.start_with?("$")
          # directive
          directive_name, args_str = statement.strip.match(/(.*)\((.*)\)/).captures
          arg_strs = args_str.split(",").map(&:strip)
          arg_strs.unshift("@")

          if self.class.directives[directive_name.strip[1..]]
            args = arg_strs.map { _convert_effect_arg_to_value _1, node }

            self.class.directives[directive_name.strip[1..]]&.(self, *args)
          end
        else
          # method call
          method_name, args_str = statement.strip.match(/(.*)\((.*)\)/).captures
          arg_strs = args_str.split(",").map(&:strip)
          arg_strs.unshift("@")

          args = arg_strs.map { _convert_effect_arg_to_value _1, node }

          send(method_name.strip, *args)
        end

        attribute.name = "host-lazy-effect"
      end
    end

    def _convert_effect_arg_to_value(arg_str, node)
      return node if arg_str == "@"

      return arg_str[1...-1] if arg_str.start_with?("'") # string literal

      if arg_str.match(/^[0-9]/)
        return arg_str.include?(".") ? arg_str.to_f : arg_str.to_i
      end

      send(arg_str[1..])
    end
  end
end
