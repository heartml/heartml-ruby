# frozen_string_literal: true

module Heartml
  module Rails
    module Helpers
      def render_heartml(&) = Heartml::TemplateRenderer.new(body: capture(&), context: self).().to_html
    end
  end
end
