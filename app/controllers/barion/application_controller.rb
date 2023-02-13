# frozen_string_literal: true

module Barion
  # Main controller for application
  class ApplicationController < ActionController::Base
    protect_from_forgery with: :exception
  end
end
