# frozen_string_literal: true

# == Schema Information
#
# Table name: barion_addresses
#
#  id         :integer          not null, primary key
#  city       :string(50)
#  country    :string(2)        default("zz")
#  full_name  :string(45)
#  region     :string(2)
#  street     :string(50)
#  street2    :string(50)
#  street3    :string(50)
#  zip        :string(16)
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
# Indexes
#
#  index_barion_addresses_on_full_name  (full_name)
#
module Barion
  class Address < ApplicationRecord
    has_many :payments, inverse_of: :shipping_address
    has_many :payments, inverse_of: :billing_address

    validates :country, presence: true, length: { is: 2 }
    validates :zip, length: { maximum: 16 }, allow_nil: true
    validates :city, length: { maximum: 50 }, allow_nil: true
    validates :region, length: { is: 2 }, allow_nil: true
    validates :street, length: { maximum: 50 }, allow_nil: true
    validates :street2, length: { maximum: 50 }, allow_nil: true
    validates :street3, length: { maximum: 50 }, allow_nil: true
    validates :full_name, length: { maximum: 45 }, allow_nil: true
  end
end
