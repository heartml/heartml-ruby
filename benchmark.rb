# frozen_string_literal: true

$LOAD_PATH.unshift File.expand_path("lib", __dir__)
require "heartml"

require_relative "test/fixtures/classes"

require "benchmark"

Benchmark.bmbm do |x|
  x.report("render") do
    1000.times do |i|
      Templated.new(name: i.to_s).()
    end
  end
end
