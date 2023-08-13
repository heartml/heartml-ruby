# frozen_string_literal: true

$LOAD_PATH.unshift File.expand_path("../lib", __dir__)
require "heartml"

require "minitest/autorun"

require_relative "fixtures/classes"
require_relative "fixtures/petite/hydrator"
require_relative "fixtures/server_effects/custom_el"
require_relative "fixtures/server_effects/effect_me"
