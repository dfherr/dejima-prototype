class GovernmentUser < ApplicationRecord
  include DejimaBase

  # attr_accessor :first_name,
  #               :last_name,
  #               :phone,
  #               :address,
  #               :birthdate

  mount_views ShareWithInsurance, ShareWithBank
end
