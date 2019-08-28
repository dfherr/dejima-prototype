class CreateInsuranceUsers < ActiveRecord::Migration[5.2]
  def change
    return unless Rails.application.config.dejima_peer_type == :insurance

    create_table :insurance_users do |t|
      t.string :first_name, null: false # shared with gov
      t.string :last_name, null: false # shared with gov
      t.string :insurance_number # not shared
      t.string :address # shared with gov
      t.date :birthdate # shared with gov
      t.string :risk_factor # shared between bank and insurance
    end
  end
end
