# frozen_string_literal: true

module Barion
  module DataFormats
    extend ActiveSupport::Concern

    def self.phone_number(number)
      number.sub(/^\+/, '').sub(/^00/, '')[0..29]
    end
  end
end
