# frozen_string_literal: true

FactoryBot.define do
  factory :barion_address, class: 'Barion::Address' do
    country { 'zz' }
  end

  factory :barion_item, class: 'Barion::Item' do
    description { Faker::String.random(length: 500) }
    name { Faker::Commerce.product_name }
    quantity { 2 }
    unit_price { Faker::Commerce.price }
    unit { Faker::String.random(length: 5) }
  end

  factory :barion_payment_transaction, class: 'Barion::PaymentTransaction' do
    pos_transaction_id { Faker::String.random }
    payee { Faker::Internet.email }
    after(:build) { |i| i.items << build(:barion_item) }
  end

  factory :barion_payment, class: 'Barion::Payment' do
    redirect_url { Faker::Internet.url }
    callback_url { Faker::Internet.url }
    after(:build) do |p|
      p.payment_transactions << build(:barion_payment_transaction)
      p.refresh_checksum
    end

    factory :barion_payment_with_address do
      billing_address { association(:barion_address) }
    end
  end

  factory :barion_payer_account, class: 'Barion::PayerAccount' do
    # no mandatory attributes
  end

  factory :barion_purchase, class: 'Barion::Purchase' do
    # no mandatory attributes
  end
end
