# frozen_string_literal: true

module Barion
  class ApplicationController < ActionController::Base
    protect_from_forgery with: :exception
  end
end
