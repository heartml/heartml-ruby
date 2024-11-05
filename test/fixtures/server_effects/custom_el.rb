# frozen_string_literal: true

class CustomEl < Heartml::ServerComponent
  define "custom-el", shadow_root: false

  attr_reader :items

  def initialize(items:, **attributes) # rubocop:disable Lint/MissingSuper
    @items = items
    @attributes = attributes
  end

  camelcased def items_length = items.length

  def attributes
    {
      items:,
      **super
    }
  end
end
