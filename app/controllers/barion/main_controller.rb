# frozen_string_literal: true

require_dependency 'barion/application_controller'

module Barion
  # Barion engine's main controller to receive callback and redirects
  class MainController < ApplicationController
    def callback
      @payment = ::Barion::Payment.find_by_payment_id(payment_params)
      if @payment.present?
        head :ok
        @payment.refresh_state
      else
        head :unprocessable_entity
      end
    end

    def land
      @payment = ::Barion::Payment.find_by_payment_id(payment_params)
    end

    private

    def payment_params
      params.require(:paymentId)
    end
  end
end
