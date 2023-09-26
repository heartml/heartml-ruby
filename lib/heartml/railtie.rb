# frozen_string_literal: true

module Heartml
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

    initializer "heartml.reload_docs_in_development" do |_app|
      unless Rails.env.production?
        ActiveSupport.on_load(:action_controller_base) do
          include ReloadDocsInDevelopment
        end
      end
    end

    config.to_prepare do
      next if Rails.env.production?

      components_folder = Rails.root.join("app", "components")
      unless File.directory?(components_folder)
        Rails.logger.error "Heartml: missing `app/components' folder, cannot load elements"
        next
      end

      Rails.autoloaders.main.eager_load_dir components_folder
    end
  end
end
