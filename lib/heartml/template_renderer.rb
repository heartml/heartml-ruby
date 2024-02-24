# frozen_string_literal: true

module Heartml
  class ServerComponent
    def self.source_location
      caller_locations(1, 10).reject do |l|
        l.label == "inherited"
      end[1].absolute_path
    end

    def self.inherited(klass)
      super
      klass.include Heartml
    end
  end

  class TemplateRenderer < ServerComponent
    def self.heart_module
      "eval"
    end

    def initialize(body:, context:) # rubocop:disable Lint/MissingSuper
      @doc_html = body.is_a?(String) ? body : body.to_html
      @body = body.is_a?(String) ? Nokolexbor::DocumentFragment.parse(body) : body
      @context = context
    end

    def call
      Fragment.new(@body, self).process
      @body
    end

    def respond_to_missing?(key)
      context.respond_to?(key)
    end

    # TODO: delegate instead?
    def method_missing(key, *args, **kwargs)
      context.send(key, *args, **kwargs)
    end
  end
end
