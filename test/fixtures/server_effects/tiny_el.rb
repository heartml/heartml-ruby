# frozen_string_literal: true

class TinyEl < Heartml::ServerComponent
  def self.source_location
    File.expand_path("tiny_el", __dir__)
  end

  define "tiny-el", shadow_root: false

  attr_reader :name

  def initialize(name:) # rubocop:disable Lint/MissingSuper
    @name = name
  end
end
