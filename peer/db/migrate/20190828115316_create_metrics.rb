class CreateMetrics < ActiveRecord::Migration[5.2]
  def change
    create_table :metrics do |t|
      t.integer 'messages_sent', default: 0
      t.integer 'messages_received', default: 0
      t.datetime 'detection_started'
      t.datetime 'detection_finished'
      t.float 'detection_time_elapsed'

      t.datetime 'last_update_request_received'
      t.integer 'update_request_count', default: 0
      t.integer 'update_request_conflict_count', default: 0
      t.datetime 'last_broadcast'
      t.integer 'broadcast_count', default: 0

      t.timestamps
    end

  end
end
