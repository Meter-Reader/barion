# frozen_string_literal: true

module Barion
  # Common data formats in Barion
  module Currencies
    extend ActiveSupport::Concern
    included do
      enum currency: { EUR: 'EUR', USD: 'USD', HUF: 'HUF', CZK: 'CZK' }, _default: :HUF
    end
  end
end
