require 'set'

class InsuranceUser < ApplicationRecord
  include DejimaBase

#   attr_accessor :first_name,
#                 :last_name,
#                 :insurance_number,
#                 :address,
#                 :phone

  link_dejima_views [{ view: ShareWithInsurance, peers: [Rails.application.config.peer_network_address, "dejima-peer1.dejima-net"].to_set }]
end