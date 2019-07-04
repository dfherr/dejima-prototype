module DejimaUtils

    def self.peer_groups
        @peer_groups ||= {}
    end

    # called by config/initializers/dejima_create_peer_groups.rb on startup
    def self.create_peer_groups(*models)
        # when creating we begin with all locally known peer groups
        self.check_local_peer_groups(models)
        Rails.logger.info "Peers groups: #{peer_groups}"
        self.detect_peer_groups
    end

    def self.compare_remote_peer_groups(remote_peer_groups)
        found_groups = Set.new
        remote_peer_groups.each do |remote_peer_group|
            peer_groups.each_value do |peer_group|
                if peer_group.dejima_tables.superset? remote_peer_group.dejima_tables
                    found_groups << peer_group
                end
            end
        end
        found_groups
    end

    # tries to detect other peer groups in the network based on the locally known peer groups
    def self.detect_peer_groups
        # now we start the network traversal
        peers_visited = Set.new(Rails.application.config.peer_network_address)
        loop do
            peers = {}

            peer_groups.each_value do |peer_group|
                peer_group.peers.each_value do |peer_address|
                    peers[peer_address] ||= Set.new
                    peers[peer_address] << peer_group
                end
            end
    
            peers_to_visit = Set.new(peers.keys) - peers_visited
            
            break if  peers_to_visit.empty?

            peers_to_visit.each do |peer_address|
                peers_visited << peer_address
                response = DejimaProxy.send_peer_group_request(peer_address, peers[peer_address].to_a)
                next if response == "connection_error"
                response.each do |peer_group|
                    if peer_groups[peer_group.dejima_tables]
                        local_group = peer_groups[peer_group.dejima_tables]
                        local_group.update peer_group
                    else
                        peer_groups[peer_group.dejima_tables] = peer_group
                        clean_duplicates
                        # TODO: remove obsolete groups
                    end
                end
    
            end
        end

        

       
        # peer_groups.each do |dejima_tables, values|
        #     # create arrays from sets for json serialization
        #     payload = {}
        #     payload[:dejima_tables] = dejima_tables.to_a
        #     payload[:attributes] = values[:attributes].to_a
        #     payload[:peers] = values[:peers].to_a
        #     visit_next = values[:peers].subtract(values[:visited]).to_a
        #     responses = DejimaProxy.send_peer_group_request(visit_next, payload)
        #     # responses example
        #     # {"dejima-peer1.dejima-net"=>
        #     #    [{"dejima_tables"=>["ShareWithInsurance", "ShareWithBank"], "attributes"=>["first_name", "last_name", "address"], "peers"=>["dejima-peer3.dejima-net", "dejima-peer2.dejima-net"]},
        #     #     {"dejima_tables"=>["ShareWithInsurance"], "attributes"=>["birthdate"], "peers"=>["dejima-peer3.dejima-net"]},
        #     #     {"dejima_tables"=>["ShareWithBank"], "attributes"=>["phone"], "peers"=>["dejima-peer2.dejima-net"]}]}
              
        #     responses.each do |peer, response|
        #         peer_groups[dejima_tables][:visited] << peer
        #         next if response == "ok" || response == "connection_error"
        #         # response contains all the entries that signal peer_group_updates
        #         response.each do |peer_group_update|
        #             # TODO:
        #         end
        #     end
        #     # TODO:
        #     # break loop and restart detection if peer_groups keys (the combination of dejima groups) changed
        #     # otherwise traverse previously unknown peers
        # end
        # TODO:
        # if break
        #self.detect_peer_groups(peer_groups)
        # else broadcast new peer groups
        #self.broadcast_peer_groups
    end

    # used to broadcast updated peer_groups to the whole network
    def self.broadcast_peer_groups(peer_groups)
        # TODO:
        # broadcast...
    end

    def self.check_local_peer_groups(models)
        attribute_to_dejima_tables = {}
        tables_to_peers = {}
        models.each do |model|
            # model.dejima_table example:
            # [{:table=>ShareWithInsurance, :peers=>#<Set: {"dejima-peer1.dejima-net", "dejima-peer3.dejima-net"}>}, 
            # {:table=>ShareWithBank, :peers=>#<Set: {"dejima-peer1.dejima-net", "dejima-peer2.dejima-net"}>}]
            model.dejima_tables.each do |dejima_table|
                dejima_table[:table].dejima_attributes.each do |attribute|
                    attribute_to_dejima_tables[[model, attribute]] = Set.new unless attribute_to_dejima_tables[[model, attribute]]
                    attribute_to_dejima_tables[[model, attribute]] << dejima_table[:table]
                    tables_to_peers[dejima_table[:table]] = Set.new unless tables_to_peers[dejima_table]
                    tables_to_peers[dejima_table[:table]] = tables_to_peers[dejima_table[:table]].union dejima_table[:peers]
                end
            end  
        end

        # attribute_to_dejima_tables_map example:
        # { 
        #   #<Set>[GovernmentUser,first_name]: [ShareWithInsurance, ShareWithBank],
        #   #<Set>[GovernmentUser,last_name]: [ShareWithInsurance, ShareWithBank],
        #   #<Set>[GovernmentUser,address]: [ShareWithInsurance, ShareWithBank],
        #   #<Set>[GovernmentUser,phone]: [ShareWithBank],
        #   #<Set>[GovernmentUser,birthdate]: [ShareWithInsurance]
        # }
        attribute_to_dejima_tables.each_pair do |attribute, dejima_tables|
            peer_group = peer_groups[dejima_tables] || PeerGroup.new(dejima_tables: dejima_tables)
            peer_group.attributes << attribute[1]
            dejima_tables.each do |dejima_table|
                peer_group.peers = peer_group.peers.union tables_to_peers[dejima_table]
            end
            peer_groups[dejima_tables] = peer_group
        end
        #[ShareWithInsurance, ShareWithBank]: attributes: [first_name, last_name, address], peers: [1,2,3]
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

    def self.format_payload(tables, attributes, peers)

    end

end