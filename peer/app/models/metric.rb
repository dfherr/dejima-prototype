class Metric < ApplicationRecord

  after_save do |metric|
    output = {}
    output[:detection_time_elapsed] = metric.detection_time_elapsed
    output[:detection_started] = metric.detection_started
    output[:detection_finished] = metric.detection_finished
    output[:messages_sent] = metric.messages_sent
    output[:messages_received] = metric.messages_received
    output[:update_request_count] = metric.update_request_count
    output[:update_request_conflict_count] = metric.update_request_conflict_count
    output[:last_update_request_received] = metric.last_update_request_received
    output[:broadcast_count] = metric.broadcast_count
    output[:last_broadcast] = metric.last_broadcast
    Rails.logger.info("Metric updated: #{output.to_json}")
  end

  def self.get_current
    order(id: :desc).first_or_create!
  end

end
