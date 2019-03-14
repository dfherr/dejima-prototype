class CreateInsuranceDejimaTable < ActiveRecord::Migration[5.2]
  def up
    return unless Rails.application.config.dejima_peer_type == :insurance
    execute File.read(Rails.root / "lib" / "dejima_sql" / "insurance_dejima_table.sql")
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
