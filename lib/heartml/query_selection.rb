# frozen_string_literal: true

module Heartml
  # Add a couple familar DOM API features to Nokolexbor
  module QuerySelection
    # @param selector [String]
    # @return [Nokolexbor::Element]
    def query_selector(selector) = at_css(selector)

    # @param selector [String]
    # @return [Nokolexbor::Element]
    def query_selector_all(selector) = css(selector)
  end

  Nokolexbor::Element.include QuerySelection unless Nokolexbor::Element.instance_methods.include?(:query_selector)
end
