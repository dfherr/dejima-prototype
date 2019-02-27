require 'set'

class BankUser < ApplicationRecord
  include DejimaBase

  # attr_accessor :first_name,
  #               :last_name,  
  #               :phone,                                
  #               :iban


  link_dejima_tables [{ table: ShareWithBank, peers: [Rails.application.config.peer_network_address, "dejima-peer1.dejima-net"].to_set }]
end
