Rails.application.config.after_initialize do

    if Rails.application.config.prototype_role == :peer && !Rake.respond_to?(:application)
        Rails.logger.info "Running as dejima peer type: #{Rails.application.config.dejima_peer_type}"

        if Rails.application.config.dejima_peer_type == :government
            DejimaUtils.create_peer_groups(GovernmentUser)
        end

        if Rails.application.config.dejima_peer_type == :bank
            DejimaUtils.create_peer_groups(BankUser)
        end

        if Rails.application.config.dejima_peer_type == :insurance
            DejimaUtils.create_peer_groups(InsuranceUser)
        end
    end

end
