require 'set'

class GovernmentUser < ApplicationRecord
  include DejimaBase

  # attr_accessor :first_name,
  #               :last_name,
  #               :phone,
  #               :address,
  #               :birthdate

  link_dejima_views [{ view: ShareWithInsurance, peers: [Rails.application.config.peer_network_address, "dejima-peer3.dejima-net"].to_set },
                    { view: ShareWithBank, peers: [Rails.application.config.peer_network_address, "dejima-peer2.dejima-net"].to_set }]
end
