# frozen_string_literal: true

module Barion
  class Transaction < ApplicationRecord
    belongs_to :payment
  end
end
