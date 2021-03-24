# frozen_string_literal: true

FactoryBot.define do
  factory :barion_address, class: '::Barion::Address' do
    country { 'zz' }
  end

  factory :barion_item, class: '::Barion::Item' do
    description { ::Faker::String.random(length: 500) }
    name { ::Faker::Commerce.product_name }
    quantity { 2 }
    unit_price { ::Faker::Commerce.price }
    unit { ::Faker::String.random(length: 5) }
  end

  factory :fix_barion_item, class: '::Barion::Item' do
    description { 'Ezittaleíráshelye' }
    name { 'Termék_x' }
    quantity { 2 }
    unit_price { 42.0 }
    unit { 'db' }
  end

  factory :barion_payment_transaction, class: '::Barion::PaymentTransaction' do
    pos_transaction_id { ::Faker::String.random }
  end

  factory :fix_barion_payment_transaction, class: '::Barion::PaymentTransaction' do
    pos_transaction_id { 'PosTr1' }
    payee { ENV['TEST_PAYEE'] }
  end

  factory :barion_payment, class: '::Barion::Payment' do
    redirect_url { ::Faker::Internet.url }
    callback_url { ::Faker::Internet.url }
    after(:build) { |p| p.refresh_checksum }

    factory :fix_barion_payment do
      poskey { ENV['TEST_POSKEY'] }
      redirect_url { 'https://example.com/redirect' }
      callback_url { 'https://example.com/callback' }
    end
  end

  factory :barion_payer_account, class: '::Barion::PayerAccount' do
    # no mandatory attributes
  end

  factory :barion_purchase, class: '::Barion::Purchase' do
    # no mandatory attributes
  end

  factory :barion_gift_card_purchase, class: '::Barion::GiftCardPurchase' do
    amount { ::Faker::Commerce.price }
    count { 10 }
  end
end
