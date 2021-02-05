# frozen_string_literal: true

require 'barion/engine'

# Main module of Barion engine
module Barion
  BASE_URL = {
    test: 'https://api.test.barion.com',
    prod: 'https://api.barion.com'
  }.freeze

  mattr_accessor :poskey, default: nil
  mattr_accessor :publickey, default: nil
  mattr_accessor :acronym, default: ''
  mattr_accessor :sandbox, default: true
  mattr_accessor :default_country, default: 'zz'
  mattr_accessor :user_class

  def sandbox?
    !!@sandbox
  end

  def sandbox=(val)
    @sandbox = !!val
  end

  # @param user_class_name [String]
  def user_class=(user_class_name)
    unless user_class_name.is_a?(String)
      raise "Barion.user_class must be set to a String, got #{user_class_name.inspect}"
    end

    @user_class_name = user_class_name
  end

  def user_class
    # This is nil before the initializer is installed.
    return nil if @user_class_name.nil?

    @user_class_name.constantize
  end

  class TamperedData < RuntimeError
  end
end
