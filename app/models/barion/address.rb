# frozen_string_literal: true

module Barion
  class Address < ApplicationRecord
    validates :country, presence: true, length: { is: 2}
    validates :zip, length: { maximum: 16 }
    validates :city, length: { maximum: 50 }
    validates :region, length: { is: 2 }
    validates :street, length: { maximum: 50 }
    validates :street2, length: { maximum: 50 }
    validates :street3, length: { maximum: 50 }
    validates :full_name, length: { maximum: 45 }
  end
end
