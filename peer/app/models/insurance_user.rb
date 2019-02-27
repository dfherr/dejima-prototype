require 'set'

class InsuranceUser < ApplicationRecord
  include DejimaBase

#   attr_accessor :first_name,
#                 :last_name,
#                 :address,
#                 :birthdate,
#                 :insurance_number


  link_dejima_tables [{ table: ShareWithInsurance, peers: [Rails.application.config.peer_network_address, "dejima-peer1.dejima-net"].to_set }]
end