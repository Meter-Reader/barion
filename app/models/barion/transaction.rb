# frozen_string_literal: true

# == Schema Information
#
# Table name: barion_transactions
#
#  id                 :integer          not null, primary key
#  currency           :string(3)
#  status             :integer
#  transaction_time   :datetime
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#  payment_id         :bigint
#  pos_transaction_id :string
#  transaction_id     :string
#
# Indexes
#
#  index_barion_transactions_on_payment_id          (payment_id)
#  index_barion_transactions_on_pos_transaction_id  (pos_transaction_id)
#  index_barion_transactions_on_status              (status)
#  index_barion_transactions_on_transaction_id      (transaction_id)
#
# Foreign Keys
#
#  payment_id  (payment_id => barion_payments.id)
#
module Barion
  class Transaction < ApplicationRecord
    belongs_to :payment, inverse_of: :transactions
  end
end
