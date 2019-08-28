require 'set'

class InsuranceUser < ApplicationRecord
  include DejimaBase
  # table columns
  # id, first_name, last_name, address, birthdate, insurance_number

  # only peers link to other peers. client only manage local
  if Rails.application.config.prototype_role == :peer
    link_dejima_tables [{ 
      table: ShareGovInsurance, 
      peers: ([Rails.application.config.peer_network_address] + Rails.application.config.share_gov_insurance_peers).to_set 
    }]
  end
end
