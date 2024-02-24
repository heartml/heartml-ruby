# frozen_string_literal: true

module TestPetiteHelpers
  def upcase_me(str)
    str.to_s.upcase
  end
  alias_method :upcaseMe, :upcase_me # rubocop:disable Style/Alias
end

require_relative "../../petite"
require "hash_with_dot_access"

class Hydrator
  include Heartml
  include Heartml::Petite
  include TestPetiteHelpers

  def self.source_location
    File.expand_path("hydrator.heartml", __dir__)
  end

  define "hydrate-me"

  attribute_binding "v-data", :data_binding

  attr_reader :count, :items, :person, :foo

  def initialize(name:, text:, count:, items: [])
    @name, @text, @count, @items = name, text, count, items.map(&:with_dot_access)

    @person = {
      name: @name
    }.with_dot_access
  end

  def attributes
    {
      te_xt: text,
      count:,
      items:,
      person:
    }
  end

  def text
    "#{@text} is TEXT!"
  end

  camelcased def button_classes
    %w[btn btn-md]
  end

  def targets
    {
      foobar_target: "nice"
    }
  end

  private

  def data_binding(attribute:, node:)
    obj = evaluate_attribute_expression(attribute)
    obj.each do |k, v|
      node["data-#{k.to_s.tr("_", "-")}"] = value_to_attribute(v) if v
    end
  end

  camelcased def big_count(num)
    num >= 20
  end
end
