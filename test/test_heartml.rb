# frozen_string_literal: true

require "test_helper"

class TestHeartml < Minitest::Test
  def test_that_it_has_a_version_number
    refute_nil ::Heartml::VERSION
  end

  def test_top_level_module
    assert_equal TopLevel.output_compare, TopLevel.new.().to_html
  end

  def test_templated_module
    htmlmod = Templated.new(name: "Thomas Anderson")

    assert_equal Templated.output_compare, htmlmod.().to_html
  end

  def test_registered_elements
    assert_equal 6, Heartml.registered_elements.length
    Object.send(:remove_const, :EffectMe)
    assert_equal 5, Heartml.registered_elements.length
    Kernel.load "fixtures/server_effects/effect_me.rb"
    assert_equal 6, Heartml.registered_elements.length
  end
end
