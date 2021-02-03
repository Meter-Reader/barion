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
#  payment_transaction_id  (payment_transaction_id => barion_transactions.id)
#
module Barion
  # Represents an item in a transaction for Barion engine
  class Item < ApplicationRecord
    belongs_to :payment_transaction,
               class_name: 'Barion::Transaction',
               inverse_of: :items

    validates :name, presence: true, length: { maximum: 256 }
    validates :description, presence: true, length: { maximum: 500 }
    validates :quantity, presence: true
    validates :unit_price, presence: true
    validates :item_total, presence: true
    validates :sku, length: { maximum: 100 }
    validates :unit, presence: true, length: { maximum: 50 }

    after_initialize :set_defaults

    attr_reader :unit_price, :quantity

    def item_total
      calculate_total
    end

    def unit_price=(value)
      @unit_price = value.to_d
      calculate_total
    end

    def quantity=(value)
      @quantity = value.to_d
    end

    private

    def set_defaults
      @quantity = 0
      @unit_price = 0.0
      calculate_total
    end

    def item_total=(_value)
      raises NoMethodError('item_total is a calculated readonly field')
    end

    def calculate_total
      @item_total = @quantity * @unit_price.to_d
    end
  end
end
