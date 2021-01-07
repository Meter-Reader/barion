# frozen_string_literal: true

module Barion
  class ApplicationRecord < ActiveRecord::Base
    self.abstract_class = true
  end
end
