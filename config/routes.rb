# frozen_string_literal: true

# == Route Map
#

Barion::Engine.routes.draw do
  get 'callback', to: 'main#callback', as: :server_callback
  get 'success', to: 'main#success', as: :payment_success
  get 'fail', to: 'main#failed', as: :payment_failed
end
