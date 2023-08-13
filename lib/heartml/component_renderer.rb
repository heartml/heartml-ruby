# frozen_string_literal: true

module Heartml
  class ComponentRenderer < Bridgetown::Builder
    def build
      render_heart_modules
    end

    # TODO: rework this using new server effects and component context!
    def render_heart_modules
      inspect_html do |doc, resource|
        view_context = Bridgetown::ERBView.new(resource)

        rdr = FragmentRenderComponent.new(body: doc.at_css("body"), scope: view_context)
        rdr.define_singleton_method(:view_context) { view_context }
        rdr.call

        # Heartml.registered_elements.each do |component|
        #   tag_name = component.tag_name
        #   doc.xpath("//#{tag_name}").reverse.each do |node|
        #     if node["server-ignore"]
        #       node.remove_attribute("server-ignore")
        #       next
        #     end

        #     attrs = node.attributes.transform_values(&:value)
        #     attrs.reject! { |k| k.start_with?("server-") }

        #     new_attrs = {}
        #     attrs.each do |k, v|
        #       next unless k.start_with?("arg:")

        #       new_key = k.delete_prefix("arg:")
        #       attrs.delete(k)
        #       new_attrs[new_key] = resource.instance_eval(v)
        #     end
        #     attrs.merge!(new_attrs)
        #     attrs.transform_keys!(&:to_sym)

        #     new_node = node.replace(
        #       component.new(**attrs).render_in(view_context, rendering_mode: :node) { node.children }
        #     )
        #     new_node.remove_attribute("server-ignore")
        #   end
        # rescue StandardError => e
        #   Bridgetown.logger.error "Unable to render <#{tag_name}> (#{component}) in #{resource.path}"
        #   raise e
        # end
      end
    end
  end
end
