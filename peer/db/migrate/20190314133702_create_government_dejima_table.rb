class CreateGovernmentDejimaTable < ActiveRecord::Migration[5.2]
  def up
    return unless Rails.application.config.dejima_peer_type == :government
    execute File.read(Rails.root / "lib" / "dejima_sql" / "government_dejima_table.sql")
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end