# frozen_string_literal: true

class CustomEl
  include Heartml
  include Heartml::ServerEffects

  def self.source_location
    File.expand_path("custom_el.heartml", __dir__)
  end

  define "custom-el", shadow_root: false

  attr_reader :items

  def initialize(items:, **attributes)
    @items = items
    @attributes = attributes
  end

  def attributes
    {
      items: items,
      **@attributes
    }
  end
end
