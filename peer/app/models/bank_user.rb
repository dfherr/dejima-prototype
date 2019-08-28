require 'set'

class BankUser < ApplicationRecord
  include DejimaBase
  # table columns
  # id, first_name, last_name, phone, iban

  # only peers link to other peers. client only manage local
  if Rails.application.config.prototype_role == :peer
    link_dejima_tables [{ 
      table: ShareGovBank, 
      peers: ([Rails.application.config.peer_network_address] + Rails.application.config.share_gov_bank_peers).to_set 
    },
    { 
      table: ShareRiskFactor, 
      peers: ([Rails.application.config.peer_network_address] + Rails.application.config.share_risk_factor_peers).to_set 
    }]
  end
end
