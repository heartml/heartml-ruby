# frozen_string_literal: true

class CustomEl < Heartml::ServerComponent
  define "custom-el", shadow_root: false

  attr_reader :items

  def initialize(items:, **attributes) # rubocop:disable Lint/MissingSuper
    @items = items
    @attributes = attributes
  end

  def attributes
    {
      items:,
      **super
    }
  end
end
