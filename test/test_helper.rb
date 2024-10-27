# frozen_string_literal: true

$LOAD_PATH.unshift File.expand_path("../lib", __dir__)
require "heartml"

require "minitest/autorun"
require "minitest/pride"

module LastNameDirective
  def self.included(klass)
    klass.directive :last_name, ->(component, node) {
      node.last_name = component.last_name
    }
  end
end

require_relative "fixtures/classes"
require_relative "fixtures/petite/hydrator"
require_relative "fixtures/server_effects/custom_el"
require_relative "fixtures/server_effects/effect_me"
require_relative "fixtures/server_effects/tiny_el"
