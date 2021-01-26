# == Schema Information
#
# Table name: barion_payers
#
#  id                               :integer          not null, primary key
#  email                            :string(256)
#  name                             :string(45)
#  locale                           :string(5)
#  phone_number                     :string(30)
#  work_phone_number                :string(30)
#  home_number                      :string(30)
#  creation_indicator               :integer
#  change_indicator                 :integer
#  password_last_changed            :datetime
#  password_change_indicator        :integer
#  suspicious                       :integer          default(FALSE)
#  payment_method_added             :datetime
#  shipping_address_usage_indicator :integer
#  shipping_address_id              :bigint
#  billing_address_id               :bigint
#  created_at                       :datetime         not null
#  updated_at                       :datetime         not null
#
require 'test_helper'

module Barion
  class PayerTest < ActiveSupport::TestCase
    # test "the truth" do
    #   assert true
    # end
  end
end
