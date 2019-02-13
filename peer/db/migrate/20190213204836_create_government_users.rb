class CreateGovernmentUsers < ActiveRecord::Migration[5.2]
  def change
    return unless Rails.configuration.peer_type == :government

    create_table :government_users do |t|
      t.string :first_name, null: false
      t.string :last_name, null: false
      t.string :phone
      t.string :address
      t.date :birthdate

      t.timestamps
    end
  end
end
