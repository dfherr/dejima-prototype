Rails.application.configure do

    config.peer_type = (ENV["PEER_TYPE"] || "government").to_sym
    
end