# frozen_string_literal: true

require "erb"

class TopLevel < Heartml::ServerComponent
  define "top-level", File.expand_path("top_level_module.heartml", __dir__)

  directive :import_css, ->(component, node) do
    node.content = File.read(File.expand_path(node[:src], File.dirname(component.class.heart_module)))
    node.ancestors.last.prepend_child node
  end

  # overridden processor
  def process_fragment(root)
    root.query_selector("article header > h1").content = "Pretty rad!"
    super
  end

  def self.output_compare
    <<~HTML.strip
      <top-level><template shadowrootmode="open"><p>I'm a paragraph.</p><section>
        <article>
          <header>
            <h1>Pretty rad!</h1>
          </header>
        </article>
      </section><link rel="stylesheet" href="styles/keep.css"><blockquote>And a blockquote!</blockquote><style>#externals {
        border: 10px solid brown;
      }
        h1 {
          color: red;
        }
      </style></template></top-level>
    HTML
  end
end

class Templated < Heartml::ServerComponent
  def self.source_location
    File.expand_path("templated_module", __dir__)
  end

  define "templated-module"

  attribute_binding "ruby:erb", :erb_binding

  attr_reader :name

  def initialize(name:) # rubocop:disable Lint/MissingSuper
    @name = name
  end

  def attributes
    {
      name:
    }
  end

  def footer
    "<small>Footer Content</small>"
  end

  def self.output_compare # rubocop:disable Metrics
    <<~HTML.strip
      <templated-module name="Thomas Anderson"><template shadowrootmode="open">
        <section>
          <article>
            <header>
              <h1 host-lazy-effect="@textContent = .name">Thomas Anderson</h1>
            </header>
            Hello <output>WORLD!</output>
            <section>
              223</section>
            <footer><small>Footer Content</small></footer>
          </article>
        </section>
      <style>
        article {
          & h1 {
            color: red;
          }
        }
      </style></template></templated-module>
    HTML
  end

  private

  def erb_binding(attribute:, node:)
    node_name = node.name
    correct_node = node_name == "template" ? node.children[0] : node
    result = ERB.new(correct_node.inner_html.strip.gsub("&lt;%", "<%").gsub("%&gt;", "%>")).result(binding)

    if node_name == "template"
      node.swap(result)
    else
      node.inner_html = result
      attribute.parent.delete(attribute.name)
    end
  end
end

class TagSwap < Heartml::ServerComponent
  def self.source_location
    File.expand_path("tag_swap", __dir__)
  end

  define "tag-swap", shadow_root: false

  output_tag_name "section"

  attr_reader :heading, :footnote

  def initialize(heading:, footnote:, **attrs) # rubocop:disable Lint/MissingSuper
    @heading, @footnote = heading, footnote
    @attrs = attrs
  end

  def attributes
    {
      **@attrs
    }
  end

  def self.output_compare
    <<~HTML.strip
      <section><header>
        <h1>I'm a heading!</h1>
      </header><p>Yay!</p> <i>It works.</i><footer>Powered by Heartml</footer></section>
    HTML
  end
end
