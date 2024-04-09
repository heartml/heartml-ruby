# frozen_string_literal: true

module Heartml
  module Rails
    class Railtie < ::Rails::Railtie
      module ReloadDocsInDevelopment
        extend ActiveSupport::Concern

        included do
          before_action :reload_docs
        end

        def reload_docs
          Heartml.registered_elements.each { _1.instance_variable_set(:@doc, nil) }
        end
      end

      require "heartml/rails/helpers"
      ActionView::Helpers.include Heartml::Rails::Helpers

      initializer "heartml.monkypatch_view_component" do |_app|
        require "view_component/base"
        require "heartml/rails/view_component_base"
        ViewComponent::Base.class_eval do
          def self.heartml = include Heartml::Rails::ViewComponentBase
        end
      rescue LoadError
        # no ViewComponent to patch
      end

      initializer "heartml.reload_docs_in_development" do |_app|
        unless ::Rails.env.production?
          ActiveSupport.on_load(:action_controller_base) do
            include ReloadDocsInDevelopment
          end
        end
      end

      config.to_prepare do
        next if ::Rails.env.production?

        components_folder = ::Rails.root.join("app", "components")
        unless File.directory?(components_folder)
          ::Rails.logger.error "Heartml: missing `app/components' folder, cannot load elements"
          next
        end

        ::Rails.autoloaders.main.eager_load_dir components_folder
      end
    end
  end
end
