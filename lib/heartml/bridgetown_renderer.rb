# frozen_string_literal: true

module Heartml
  class BridgetownRenderer < Bridgetown::Builder
    def build
      render_heart_modules
    end

    def render_heart_modules
      inspect_html do |doc, resource|
        view_context = Bridgetown::ERBView.new(resource)

        rdr = Heartml::TemplateRenderer.new(body: doc.at_css("body"), context: view_context)
        rdr.call
      end
    end
  end
end

Bridgetown.initializer :heartml do |config|
  # TODO: maybe we can ditch this once we're off ActiveSupport in Bridgetown
  Bridgetown::Component.extend ActiveSupport::DescendantsTracker

  Heartml.module_eval do
    def render_in(view_context, rendering_mode: :string, &block)
      self.rendering_mode = rendering_mode
      super(view_context, &block)
    end
  end

  Heartml::ClassMethods.module_eval do
    def component_template_path = heart_module
  end

  # Eager load all components
  config.hook :site, :after_reset do |site|
    unless site.config.eager_load_paths.find { _1.end_with?(site.config.components_dir) }
      site.config.eager_load_paths << site.config.autoload_paths.find { _1.end_with?(site.config.components_dir) }
    end
  end

  config.html_inspector_parser "nokolexbor"
  config.builder Heartml::BridgetownRenderer
end
