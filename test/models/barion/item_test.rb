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
require 'test_helper'

module Barion
  # Test constrains of Barion::Item
  class ItemTest < ActiveSupport::TestCase
    setup do
      @item = build(:barion_item)
      @item.payment_transaction = build(:barion_payment_transaction)
      @json = @item.as_json
    end

    test 'name is mandatory' do
      assert_valid @item
      assert @json['Name']
      @item.name = nil

      refute_valid @item
      refute @item.as_json['Name']
    end

    test 'name max length 256 chars' do
      assert_valid @item
      @item.name = Faker::String.random(length: 257)

      refute_valid @item
      @item.name = Faker::String.random(length: 256)

      assert_valid @item
    end

    test 'description is mandatory' do
      assert_valid @item
      assert @json['Description']
      @item.description = nil

      refute_valid @item
      refute @item.as_json['Description']
    end

    test 'description max length 500 chars' do
      assert_valid @item
      @item.description = Faker::String.random(length: 501)

      refute_valid @item
      @item.description = Faker::String.random(length: 500)

      assert_valid @item
    end

    test 'image_url has no default value' do
      assert_nil @item.image_url
      refute @json['ImageUrl']
      assert_valid @item
    end

    test 'image_url can be set' do
      @item.image_url = 'Test'

      assert_valid @item
      assert_equal 'Test', @item.image_url
      assert_equal 'Test', @item.as_json['ImageUrl']
    end

    test 'item_total can be set' do
      assert_valid @item
      @item.item_total = 42

      assert_equal 42, @item.item_total
      assert_equal '42.0', @item.as_json['ItemTotal']
    end

    test 'item_total is calculated from quantity and unit_price' do
      assert_valid @item
      assert @json['ItemTotal']
      @item.quantity = 12
      @item.unit_price = 2

      assert_in_delta(24.0, @item.item_total)
      assert_equal '24.0', @item.as_json['ItemTotal']
      @item.quantity = 13

      assert_equal 26, @item.item_total
      assert_equal '26.0', @item.as_json['ItemTotal']
      @item.unit_price = 3.1

      assert_in_delta(40.3, @item.item_total)
      assert_equal '40.3', @item.as_json['ItemTotal']
    end

    test 'unit is mandatory with no default and can be set' do
      assert_valid @item
      refute_nil @item.unit
      assert @json['Unit']
      @item.unit_price = nil

      assert_valid @item
    end

    test 'unit max length is 50 chars' do
      assert_valid @item
      @item.unit = Faker::String.random(length: 51)

      refute_valid @item
      @item.unit = Faker::String.random(length: 50)

      assert_valid @item
    end

    test 'unit_price mandatory, default 0 but can be set' do
      assert_valid @item
      refute_nil @item.unit_price
      assert @json['UnitPrice']
      @item.unit_price = nil

      assert_equal 0, @item.unit_price
      assert_equal '0.0', @item.as_json['UnitPrice']
      assert_valid @item
    end

    test 'quantity is mandatory, default 0 but can be set' do
      assert_valid @item
      refute_nil @item.quantity
      assert @json['Quantity']
      @item.quantity = nil

      assert_equal 0, @item.quantity
      assert_equal '0.0', @item.as_json['Quantity']
      assert_valid @item
      @item.quantity = 2

      assert_valid @item
      assert_in_delta(2.0, @item.quantity)
      assert_equal '2.0', @item.as_json['Quantity']
    end

    test 'sku has no default value and optional' do
      assert_valid @item
      assert_nil @item.sku
      refute @json['SKU']
    end

    test 'sku can be set' do
      assert_valid @item
      assert_nil @item.sku
      refute @json['SKU']
      @item.sku = 'Test'

      assert_valid @item
      assert_equal 'Test', @item.sku
      assert_equal 'Test', @item.as_json['SKU']
    end

    test 'sku max length is 100 chars' do
      assert_valid @item
      assert_nil @item.sku
      @item.sku = Faker::String.random(length: 101)

      refute_valid @item
      @item.sku = Faker::String.random(length: 100)

      assert_valid @item
    end
  end
end
