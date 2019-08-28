Rails.application.configure do
  if config.prototype_role == :peer
    config.dejima_peer_type = (ENV["PEER_TYPE"] || "government").to_sym
    config.share_gov_bank_peers = (ENV["SHARE_GOV_BANK_PEERS"]&.split(";") || [])
    config.share_gov_insurance_peers = (ENV["SHARE_GOV_INSURANCE_PEERS"]&.split(";") || [])
    config.share_between_banks_peers = (ENV["SHARE_BETWEEN_BANKS_PEERS"]&.split(";") || [])
    config.peer_network_address = ENV["PEER_NETWORK_ADDRESS"]
  end
end
