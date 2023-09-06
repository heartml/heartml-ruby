# frozen_string_literal: true

class TinyEl < Heartml::ServerComponent
  def self.source_location
    File.expand_path("tiny_el", __dir__)
  end

  define "tiny-el", shadow_root: false

  attr_reader :name, :last_name

  def initialize(name:, last_name:) # rubocop:disable Lint/MissingSuper
    @name = name
    @last_name = last_name
  end

  camelcased def full_name
    "#{name} #{last_name}"
  end
end
