class CreateBankUsers < ActiveRecord::Migration[5.2]
  def change
    return unless Rails.application.config.dejima_peer_type == :bank

    create_table :bank_users do |t|
      t.string :first_name, null: false # shard with gov
      t.string :last_name, null: false  # shard with gov
      t.string :iban # not shared
      t.string :address  # shard with gov
      t.string :phone # not shared
      t.string :risk_factor # shared between bank and insurance
    end
  end
end
