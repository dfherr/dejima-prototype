class InsuranceUser < ApplicationRecord
  include DejimaBase

#   attr_accessor :first_name,
#                 :last_name,
#                 :insurance_number,
#                 :address,
#                 :phone

  mount_view ShareWithInsurance
end