require 'set'

class BankUser < ApplicationRecord
  include DejimaBase
  # table columns
  # id, first_name, last_name, phone, iban

  # only peers link to other peers. client only manage local
  if Rails.application.config.prototype_role == :peer
    link_dejima_tables [{ table: ShareWithBank, peers: [Rails.application.config.peer_network_address, "dejima-gov-peer.dejima-net"].to_set }]
  end
end
