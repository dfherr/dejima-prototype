module DejimaUtils
    
    def self.create_peer_groups(*models)
        # when creating we begin with all locally known peer groups
        peer_groups = DejimaUtils.check_local_peer_groups(models)
        puts "Peers groups: #{peer_groups}"

        # now we start the network traversal
        peer_groups.each_value do |payload|
            # create arrays from sets for json serialization
            payload[:values] = payload[:values].to_a
            payload[:peers] = payload[:peers].to_a
            DejimaClient.send_peer_group_request(payload[:peers], payload)
        end
    end

    def self.check_local_peer_groups(models)
        attribute_to_views = {}
        views_to_peers = {}
        models.each do |model|
            # model.dejima_view structure:
            # [{:view=>ShareWithInsurance, :peers=>#<Set: {"dejima-peer1.dejima-net", "dejima-peer3.dejima-net"}>}, 
            # {:view=>ShareWithBank, :peers=>#<Set: {"dejima-peer1.dejima-net", "dejima-peer2.dejima-net"}>}]
            model.dejima_views.each do |dejima_view|
                dejima_view[:view].dejima_attributes.each do |attribute|
                    attribute_to_views[[model, attribute]] = Set.new unless attribute_to_views[[model, attribute]]
                    attribute_to_views[[model, attribute]] << dejima_view[:view]
                    views_to_peers[dejima_view[:view]] = Set.new unless views_to_peers[dejima_view]
                    views_to_peers[dejima_view[:view]] = views_to_peers[dejima_view[:view]].union dejima_view[:peers]
                end
            end  
        end

        # attribute_to_views_map structure:
        # { 
        #   first_name: [ShareWithInsurance, ShareWithBank],
        #   last_name: [ShareWithInsurance, ShareWithBank],
        #   address: [ShareWithInsurance, ShareWithBank],
        #   phone: [ShareWithBank],
        #   irthdate: [ShareWithInsurance]
        # }
        peer_groups = {}
        attribute_to_views.each_pair do |attribute, views|
            peer_groups[views] = { values: Set.new, peers: Set.new } unless peer_groups[views]
            peer_groups[views][:values] << "#{views.to_a.join("&&")}##{attribute[1]}"
            views.each do |view|
                peer_groups[views][:peers] = peer_groups[views][:peers].union views_to_peers[view]
            end
        end
        peer_groups
    end

    # hardcode for now
    def self.identify_bases(values)
        if Rails.application.config.dejima_peer_type == :government
            return [GovernmentUser]
        elsif Rails.application.config.dejima_peer_type == :bank
            return [BankUser]
        elsif Rails.application.config.dejima_peer_type == :insurance
            return [InsuranceUser]
        else
            []
        end
    end

end