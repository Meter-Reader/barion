# frozen_string_literal: true

# == Schema Information
#
# Table name: barion_transactions
#
#  id                    :integer          not null, primary key
#  comment               :string
#  currency              :string(3)
#  payee                 :string           not null
#  status                :integer          default("Prepared"), not null
#  total                 :decimal(, )      not null
#  transaction_time      :datetime
#  created_at            :datetime         not null
#  updated_at            :datetime         not null
#  payee_transactions_id :bigint
#  payment_id            :bigint
#  pos_transaction_id    :string           not null
#  transaction_id        :string
#
# Indexes
#
#  index_barion_transactions_on_payee                  (payee)
#  index_barion_transactions_on_payee_transactions_id  (payee_transactions_id)
#  index_barion_transactions_on_payment_id             (payment_id)
#  index_barion_transactions_on_pos_transaction_id     (pos_transaction_id)
#  index_barion_transactions_on_status                 (status)
#  index_barion_transactions_on_transaction_id         (transaction_id)
#
# Foreign Keys
#
#  payee_transactions_id  (payee_transactions_id => barion_transactions.id)
#  payment_id             (payment_id => barion_payments.id)
#
require 'test_helper'

module Barion
  class TransactionTest < ActiveSupport::TestCase
    # test "the truth" do
    #   assert true
    # end
  end
end
