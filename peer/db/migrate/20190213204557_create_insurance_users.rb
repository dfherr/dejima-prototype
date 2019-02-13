class CreateInsuranceUsers < ActiveRecord::Migration[5.2]
  def change
    return unless Rails.configuration.peer_type == :insurance

    create_table :insurance_users do |t|
      t.string :first_name, null: false
      t.string :last_name, null: false
      t.string :insurance_number
      t.string :address
      t.string :phone
      
      t.timestamps
    end
  end
end
