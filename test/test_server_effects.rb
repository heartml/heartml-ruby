# frozen_string_literal: true

require "test_helper"

class TestServerEffects < Minitest::Test
  # rubocop:disable Layout/LineLength
  def test_effect_me
    context = {
      last_name: "Wh<em>it</em>e"
    }.with_dot_access

    renderer = Heartml::TemplateRenderer.new(body: <<~HTML, context: context)
      <effect-me first-name="Ja&lt;em&gt;re&lt;em&gt;d" aria-label="Labeled" server-args="last_name">Neato</effect-me>
    HTML

    results = renderer.().to_html

    assert_includes results, %(aria-label="LABELED")
    assert_includes results, %(>Ja&lt;em&gt;re&lt;em&gt;d</p>)
    assert_includes results, %(>Wh<em>it</em>e</p>)
    assert_includes results, %(aria-label="Last Name")
    assert_includes results, %(>JA&lt;EM&gt;RE&lt;EM&gt;D, yo</aside>)
    assert_includes results, %( hidden="">I am hidden</output>)
    assert_includes results, %( class="foo-bar">address</address>)
    assert_includes results, "<custom-el items=\"{&quot;item_1&quot;:[&quot;string&quot;,true],&quot;item_2&quot;:[123,{&quot;checked&quot;:false}]}\""
    assert_includes results, "<p>Woo hoo! 2 items.</p><em>Children.</em>\n  <tiny-el><p>Ja&lt;em&gt;re&lt;em&gt;d</p></tiny-el>\n</custom-el></template>\n  Here's content! Yay! Neato.\n</effect-me>"
  end
  # rubocop:enable Layout/LineLength
end
