class ShareBetweenBanks
  include DejimaTable

  define_attribute  :first_name,
                    :last_name,
                    :address,
                    :phone,
                    :credit_score
end
