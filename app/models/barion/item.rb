# frozen_string_literal: true

# == Schema Information
#
# Table name: barion_items
#
#  id                     :integer          not null, primary key
#  description            :string(500)      not null
#  image_url              :string
#  item_total             :decimal(, )      not null
#  name                   :string(250)      not null
#  quantity               :decimal(, )      not null
#  sku                    :string(100)
#  unit                   :string(50)       not null
#  unit_price             :decimal(, )      not null
#  payment_transaction_id :integer
#
# Indexes
#
#  index_barion_items_on_payment_transaction_id  (payment_transaction_id)
#
# Foreign Keys
#
#  payment_transaction_id  (payment_transaction_id => barion_payment_transactions.id)
#
module Barion
  # Represents an item in a transaction for Barion engine
  class Item < ApplicationRecord
    belongs_to :payment_transaction,
               inverse_of: :items

    attribute :name, :string
    attribute :description, :string
    attribute :unit_price, :decimal, default: 0.0
    attribute :quantity, :decimal, default: 0.0
    attribute :item_total, :decimal, default: 0.0
    attribute :unit, :string

    validates :name, presence: true, length: { maximum: 256 }
    validates :description, presence: true, length: { maximum: 500 }
    validates :quantity, presence: true
    validates :unit_price, presence: true
    validates :item_total, presence: true
    validates :sku, length: { maximum: 100 }
    validates :unit, presence: true, length: { maximum: 50 }

    after_initialize :set_defaults

    def unit_price=(value)
      super(value.to_d)
      calculate_total
    end

    def quantity=(value)
      super(value.to_d)
      calculate_total
    end

    def item_total=(_value)
      raise ::NoMethodError, 'item_total is a calculated readonly field'
    end

    private

    def set_defaults
      calculate_total
    end

    def calculate_total
      self[:item_total] = (quantity * unit_price.to_d)
    end
  end
end
