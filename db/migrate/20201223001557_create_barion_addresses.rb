# frozen_string_literal: true

class CreateBarionAddresses < ActiveRecord::Migration[6.0]
  def change
    create_table :barion_addresses do |t|
      t.string :country, limit: 2, default: 'zz'
      t.string :zip, limit: 16
      t.string :city, limit: 50
      t.string :region, limit: 2
      t.string :street, limit: 50
      t.string :street2, limit: 50
      t.string :street3, limit: 50
      t.string :full_name, limit: 45

      t.timestamps
    end
    add_index :barion_addresses, :full_name
  end
end
