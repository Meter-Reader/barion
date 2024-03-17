# frozen_string_literal: true

# Barion related functions
module Barion
  # Adds Barion Pixel javascript to views
  require 'action_view'
  # Provides functions for Barion Pixel implementations in views
  module PixelHelper
    include ActionView::Helpers::TagHelper
    def pixel_basic_js
      javascript_tag %(
      window["bp"] = window["bp"] || function () {(window["bp"].q = window["bp"].q || []).push(arguments);};
      window["bp"].l = 1 * new Date();
      scriptElement = document.createElement("script");
      firstScript = document.getElementsByTagName("script")[0];
      scriptElement.async = true;
      scriptElement.src = 'https://pixel.barion.com/bp.js';
      firstScript.parentNode.insertBefore(scriptElement, firstScript);
      window['barion_pixel_id'] = '#{::Barion.config.pixel_id}';
      // Send init event
      bp('init', 'addBarionPixelId', window['barion_pixel_id']);'
).gsub!(/^#{[/\A\s*/]}/, '')
    end

    def pixel_basic_noscript
      tag.noscript do
        tag.img height: 1, width: 1,
                style: 'display:none',
                alt: 'Barion Pixel',
                src: "https://pixel.barion.com/a.gif?ba_pixel_id='#{::Barion.config.pixel_id}'&ev=contentView&noscript=1"
      end
    end

    def pixel_basic_tags
      pixel_basic_js + pixel_basic_noscript
    end
  end
end
