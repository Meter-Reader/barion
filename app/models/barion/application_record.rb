# frozen_string_literal: true

module Barion
  # Abstract data record class
  #
  # @abstract
  class ApplicationRecord < ActiveRecord::Base
    self.abstract_class = true
  end
end
