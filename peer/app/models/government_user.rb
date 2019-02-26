require 'set'

class GovernmentUser < ApplicationRecord
  include DejimaBase

  # attr_accessor :first_name,
  #               :last_name,
  #               :phone,
  #               :address,
  #               :birthdate

  link_dejima_tables [{ table: ShareWithInsurance, peers: [Rails.application.config.peer_network_address, "dejima-peer3.dejima-net"].to_set },
                    { table: ShareWithBank, peers: [Rails.application.config.peer_network_address, "dejima-peer2.dejima-net"].to_set }]
end
