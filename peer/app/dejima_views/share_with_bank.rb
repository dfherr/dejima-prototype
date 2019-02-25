class ShareWithBank
  include DejimaView
  
  define_attribute  :first_name,
                    :last_name,
                    :phone,
                    :address

  def self.compare(view)
    
  end

end