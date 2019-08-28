class PeerGroupDetectionJob < ApplicationJob
  queue_as :default
 
  def perform
    Metric.create do |m|
      m.detection_started = Time.now
    end
    DejimaManager.detect_peer_groups
    Metric.get_current.update!(detection_finished: Time.now)
    time_elapsed = Metric.get_current.detection_finished - Metric.get_current.detection_started
    Rails.logger.info("Detection time elapsed: #{time_elapsed}")
    Rails.logger.info("Peer groups after peer group detection job: #{PeerGroups.get.values.to_json}")
    Metric.get_current.update!(detection_time_elapsed: time_elapsed)
  end
end