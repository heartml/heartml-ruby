# frozen_string_literal: true

module Heartml
  module Rails
    module ViewComponentBase
      def self.included(klass)
        klass.remove_method :render_template_for
        klass.extend ClassMethods
        klass.include Heartml
      end

      def render_in(view_context, rendering_mode: :string, &block)
        self.rendering_mode = rendering_mode
        super(view_context, &block)
      end

      def render_template_for(*) = call

      module ClassMethods
        def compile(*)
          # no-op
        end

        def compiled? = true

        def inherited(klass)
          super(klass)
          klass.source_location = caller_locations(1, 10).reject { |l| l.label == "inherited" }[0].path
          klass.virtual_path = klass.source_location.gsub(
            %r{(.*#{Regexp.quote(ViewComponent::Base.config.view_component_path)})|(\.rb)}, ""
          )
          Heartml::ServerEffects.included_extras(klass)
          klass.directives.merge! directives
        end
      end
    end
  end
end