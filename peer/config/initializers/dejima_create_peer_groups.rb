Rails.application.config.after_initialize do
  if Rails.application.config.prototype_role == :peer && defined?(::Rails::Server) && !Rails.env.to_s.match(/test/)
    Rails.logger.info "Running as dejima peer type: #{Rails.application.config.dejima_peer_type}"
    PeerGroupsStore.get.delete
    DejimaManager.create_peer_groups(GovernmentUser) if Rails.application.config.dejima_peer_type == :government
    DejimaManager.create_peer_groups(BankUser) if Rails.application.config.dejima_peer_type == :bank
    DejimaManager.create_peer_groups(InsuranceUser) if Rails.application.config.dejima_peer_type == :insurance
    PeerGroupDetectionJob.set(wait: 15.seconds).perform_later
  end
end
