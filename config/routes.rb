# frozen_string_literal: true

# == Route Map
#

::Barion::Engine.routes.draw do
  post 'callback', to: 'main#callback', as: :gateway_callback
  get 'land', to: 'main#land', as: :gateway_back
end
