require 'set'

class BankUser < ApplicationRecord
  include DejimaBase

  # attr_accessor :first_name,
  #               :last_name,                                    
  #               :iban,
  #               :phone

  link_dejima_views [{ view: ShareWithBank, peers: [Rails.application.config.peer_network_address, "dejima-peer1.dejima-net"].to_set }]
end
