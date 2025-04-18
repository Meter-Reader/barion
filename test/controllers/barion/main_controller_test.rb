# frozen_string_literal: true

module Barion
  class MainControllerTest < ActionDispatch::IntegrationTest
    include ::Barion::Engine.routes.url_helpers

    def setup
      @routes = ::Barion::Engine.routes
      @routes.default_url_options[:host] = 'example.com'
      ::Barion.config.sandbox = true
      @poskey = 'test_poskey'
      ::Barion.config.poskey = @poskey
      ::Barion.config.default_payee = 'test'
      @payment = build(:fix_barion_payment)
      tr = build(:fix_barion_payment_transaction)
      tr.items << build(:fix_barion_item)
      @payment.payment_transactions << tr
      @payment.payment_id = ::Faker::Alphanumeric.alphanumeric(number: 10)
      @payment.save
      @payment.refresh_checksum
      @payment.save
    end

    def test_gateway_callback_with_wrong_id
      post barion.gateway_callback_url, params: { paymentId: 'test' }

      assert_response :unprocessable_entity
    end

    def test_gateway_callback_with_correct_id
      assert_raises(VCR::Errors::UnhandledHTTPRequestError) do
        post barion.gateway_callback_url, params: {
          paymentId: @payment.payment_id
        }
      end
    end

    def test_gateway_back
      get barion.gateway_back_url, params: {
        paymentId: @payment.payment_id
      }

      assert_response :success
    end

    def test_engine_root
      assert_generates '/barion/', controller: 'barion/main', action: 'land'
      assert_recognizes(
        { controller: 'barion/main', action: 'land' },
        { path: '/', method: :get }
      )
    end

    def test_callback_route
      assert_generates '/barion/callback', controller: 'barion/main', action: 'callback'
      assert_recognizes(
        { controller: 'barion/main', action: 'callback' },
        { path: '/callback', method: :post }
      )
    end
  end
end
