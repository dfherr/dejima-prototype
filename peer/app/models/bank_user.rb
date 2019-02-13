class BankUser < ApplicationRecord
  include DejimaBase

  # attr_accessor :first_name,
  #               :last_name,                                    
  #               :iban,
  #               :phone

  mount_views ShareWithBank
end
