# frozen_string_literal: true

require "test_helper"

class TestPetite < Minitest::Test
  def test_hydrator
    htmlmod = Hydrator.new(name: "Jordan", count: 10, text: "Ten is 10",
                           items: [{ name: "xyz", subitems: [{ name: "sub!" }] }])
    results = htmlmod.().to_html

    assert_includes results, "Jordan ...:"
    assert_includes results, %(class="high-light">10</h3>)
    assert_includes results, %(data-foobar-target="nice" class="btn btn-md">Click Me!!</button>)
    assert_includes results, %(person="{&quot;name&quot;:&quot;Jordan&quot;}")
    assert_includes results, %(color: darkcyan;)
  end
end
