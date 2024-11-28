# frozen_string_literal: true

require "test_helper"

class TestServerEffects < Minitest::Test
  # rubocop:disable Layout/LineLength
  def test_effect_me
    context = {
      last_name: "Wh<em>it</em>e"
    }.with_dot_access

    renderer = Heartml::TemplateRenderer.new(body: <<~HTML, context:)
      <effect-me host-effect="KEEP" first-name="Ja&lt;em&gt;re&lt;em&gt;d" aria-label="Labeled" goo-bar="123" server-args="last_name">Neato</effect-me>
    HTML

    results = renderer.().to_html

    assert_includes results, %(host-effect="KEEP")
    assert_includes results, %(aria-label="LABELED" goo-bar="123")
    refute_includes results, "globs="
    assert_includes results, %(>Ja&lt;em&gt;re&lt;em&gt;d</p>)
    assert_includes results, %(>Wh<em>it</em>e</p>)
    assert_includes results, %(aria-label="Last Name")
    assert_includes results, %(<aside>JA&lt;EM&gt;RE&lt;EM&gt;D, yo</aside>)
    assert_includes results, %( hidden="">I am hidden</output>)
    assert_includes results, %( class="foo-bar">address</address>)
    assert_includes results, "<custom-el items=\"{&quot;item_1&quot;:[&quot;string&quot;,true],&quot;item_2&quot;:[123,{&quot;checked&quot;:false}]}\""
    assert_includes results, "<p>Woo hoo! <b>2</b> items.</p><em>Children.</em>\n  <tiny-el><p aria-hidden=\"true\">Ja&lt;em&gt;re&lt;em&gt;d Wh&lt;em&gt;it&lt;/em&gt;e</p></tiny-el>\n</custom-el>\n</template>\n  Here's content! Yay! Neato.\n</effect-me>"
  end
  # rubocop:enable Layout/LineLength

  def test_tag_swap
    renderer = Heartml::TemplateRenderer.new(body: <<~HTML, context: {})
      <tag-swap heading="I'm a heading!" footnote="Powered by Heartml"><p>Yay!</p> <i>It works.</i></tag-swap>
    HTML

    results = renderer.().to_html

    assert_equal TagSwap.output_compare, results.strip
  end
end
