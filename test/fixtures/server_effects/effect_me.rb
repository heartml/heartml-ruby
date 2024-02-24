# frozen_string_literal: true

class EffectMe < Heartml::ServerComponent
  include LastNameDirective

  define "effect-me"

  camelcased attr_reader :first_name, :last_name

  def initialize(first_name:, last_name:, **attributes) # rubocop:disable Lint/MissingSuper
    @first_name = first_name
    @last_name = last_name
    @attributes = attributes
  end

  def attributes
    {
      first_name:,
      last_name:,
      globs: nil, # test nil values are filtered out
      **super,
      aria_label: @attributes[:aria_label].upcase
    }
  end

  camelcased def label_name = "Last Name"

  camelcased def more_info(element, value)
    element.content = "#{value.upcase}, yo"
  end

  def bye = true

  camelcased def address_classes
    {
      "foo-bar" => true,
      "bar-baz" => false
    }
  end

  # rubocop:disable Naming/VariableNumber
  def items_object
    {
      item_1: ["string", true],
      item_2: [123, { checked: false }]
    }
  end
  # rubocop:enable Naming/VariableNumber
end
