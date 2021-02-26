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
  mattr_accessor :item_class

  def self.sandbox?
    !!sandbox
  end

  def sandbox=(val)
    super(!!val)
  end

  def self.endpoint
    env = sandbox? ? :test : :prod
    ::RestClient::Resource.new BASE_URL[env]
  end

  def self.user_class=(user_class_name)
    unless user_class_name.is_a?(String)
      raise ArgumentError, "Barion.user_class must be set to a String, got #{user_class_name.inspect}"
    end

    @user_class_name = user_class_name
  end

  def self.user_class
    # This is nil before the initializer is installed.
    return nil if @user_class_name.nil?

    @user_class_name.constantize
  end

  def self.item_class=(item_class_name)
    unless item_class_name.is_a?(String)
      raise ArgumentError, "Barion.item_class must be set to a String, got #{item_class_name.inspect}"
    end

    @item_class_name = item_class_name
  end

  def self.item_class
    # This is nil before the initializer is installed.
    return nil if @item_class_name.nil?

    @item_class_name.constantize
  end

  # Error to signal the data in the db has been changed since saving it
  class TamperedData < RuntimeError
  end

  # Generic error class for Barion module
  class Error < StandardError
    def initialize(params)
      @title = params[:Title]
      @error_code = params[:ErrorCode]
      @happened_at = params[:HappenedAt]
      @auth_data = params[:AuthData]
      @endpoint = params[:Endpoint]
      @errors = params[:Errors].map { |e| Barion::Error.new(e) } if params.key? :Errors
      super(params[:Description])
    end
  end
end
