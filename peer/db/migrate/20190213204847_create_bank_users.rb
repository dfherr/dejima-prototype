class CreateBankUsers < ActiveRecord::Migration[5.2]
  def change
    return unless Rails.configuration.peer_type == :bank

    create_table :bank_users do |t|
      t.string :first_name, null: false
      t.string :last_name, null: false
      t.string :iban
      t.string :address
      t.string :phone
      
      t.timestamps
    end
  end
end
