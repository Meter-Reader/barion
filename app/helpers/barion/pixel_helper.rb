# frozen_string_literal: true

# typed: true

module Barion
  # Adds Barion Pixel javascript to views
  module PixelHelper
    def pixel_basic_js
      javascript_tag %(
      window["bp"] = window["bp"] || function () {(window["bp"].q = window["bp"].q || []).push(arguments);};
      window["bp"].l = 1 * new Date();
      scriptElement = document.createElement("script");
      firstScript = document.getElementsByTagName("script")[0];
      scriptElement.async = true;
      scriptElement.src = 'https://pixel.barion.com/bp.js';
      firstScript.parentNode.insertBefore(scriptElement, firstScript);
      window['barion_pixel_id'] = '#{::Barion.pixel_id}';
      // Send init event
      bp('init', 'addBarionPixelId', window['barion_pixel_id']);'
).gsub!(/^#{[/\A\s*/]}/, '')
    end
  end
end
