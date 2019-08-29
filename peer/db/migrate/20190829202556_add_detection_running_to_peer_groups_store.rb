class AddDetectionRunningToPeerGroupsStore < ActiveRecord::Migration[5.2]
  def change
    add_column :peer_groups_stores, :detection_running, :boolean
  end
end
