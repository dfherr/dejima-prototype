class CreateGovernmentUsers < ActiveRecord::Migration[5.2]
  def change
    return unless Rails.application.config.dejima_peer_type == :government

    create_table :government_users do |t|
      t.string :first_name, null: false # shared with bank and insurance
      t.string :last_name, null: false # shared with bank and insurance
      t.string :phone # shared with bank, but not insurance
      t.string :address # shared with bank and insurance
      t.date :birthdate # shared insurance, but not bank

      t.timestamps
    end
  end
end
