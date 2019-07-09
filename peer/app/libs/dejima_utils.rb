module DejimaUtils

    def self.peer_groups
        PeerGroups.instance.groups
    end

    # called by config/initializers/dejima_create_peer_groups.rb on startup
    def self.create_peer_groups(*models)
        # when creating we begin with all locally known peer groups
        self.check_local_peer_groups(models)
        Rails.logger.info "Peers groups: #{peer_groups}"
        self.detect_peer_groups
    end

    # compares remote peer groups to the locally known peer groups
    # returns all local groups that have shared Dejima tables with a remote peer group,
    # i.e. the set intersection is not empty
    #
    # this is used for responding to peer detection requests
    # the requesting peer gets all groups relevant for him, because dependent Dejima tables
    # are either already in the same peer group or in another peer group, that is a super or subset.
    def self.compare_remote_peer_groups(remote_peer_groups)
        found_groups = Set.new
        remote_peer_groups.each do |remote_peer_group|
            binding.pry
            peer_groups.each_value do |peer_group|
                if peer_group.dejima_tables.intersect? remote_peer_group.dejima_tables
                    found_groups << peer_group
                end
            end
        end
        found_groups
    end

    # tries to detect other peer groups in the network based on the locally known peer groups
    def self.detect_peer_groups
        # now we start the network traversal
        peers_visited = Set.new([Rails.application.config.peer_network_address])
        while(true)
            peers = {}

            # map peer addresses to peer_groups connected to this peer
            peer_groups.each_value do |peer_group|
                peer_group.peers.each do |peer_address|
                    peers[peer_address] ||= Set.new
                    peers[peer_address] << peer_group
                end
            end
    
            peers_to_visit = Set.new(peers.keys) - peers_visited
            
            break if peers_to_visit.empty?

            peers_to_visit.each do |peer_address|
                peers_visited << peer_address
                response = DejimaProxy.send_peer_group_request(peer_address, peers[peer_address].to_a)
                next if response == "connection_error"
                response.each do |peer_group|
                    add_new_peer_group peer_group
                end
            end
        end

        #self.broadcast_peer_groups
    end

    # This function adds new_group to the locally known peer_groups
    #
    # We need to detect all intersections between our known groups in peer_groups
    # and the new group that needs to be added to our peer groups
    #
    # In our existing peer_groups no peer_group shares any attributes with
    # another peer group, i.e. each attribute is exactly assigned to one peer group.
    #
    # For every intersection between dejima_tables of our peer groups and the new groups
    # we need to create or update the peer_group of the union of the dejima_tables with
    # the intersection of the attributes
    # 
    # This might create new, larger peer groups and make existing groups obsolete.
    #
    # If new_group is disjoint to all local peer groups, it means this group has no
    # shared attributes and thus no relevance to this peer. It shouldn't have reached
    # this method in the first place.
    #
    # This algorithm could be optimized by removing handled attributes from new_group
    # on each iteration and breaking early once new_group.attributes is empty
    # 
    def self.add_new_peer_group(new_group)
        peer_groups.each do |peer_group|
            next if peer_group.dejima_tables.disjoint? new_group.dejima_tables
            shared_attributes = peer_group.attributes.intersection new_group.attributes
            next if shared_attributes.empty?
            dejima_table_union = peer_group.dejima_tables.union new_group.dejima_tables
            if peer_groups[dejima_table_union]
                peer_groups[dejima_table_union].update_peers(new_group)
            else
                # create combined peer group, if it doesn't already exist
                combined_peer_group = PeerGroup.new(
                    dejima_tables: dejima_table_union,
                    attributes: shared_attributes,
                    peers: (peer_group.peers.union new_group.peers)
                )
                peer_groups[dejima_table_union] = combined_peer_group
            end
            # remove attributes that moved to the new union group from existing group
            # unless the union group and existing group are identical
            if peer_group.dejima_tables != dejima_table_union
                updated_group = PeerGroup.new(
                    dejima_tables: peer_group.dejima_tables,
                    attributes: (peer_group.attributes - shared_attributes), # shared "moved up" to the union group
                    peers: peer_group.peers 
                )
                if updated_group.attributes.empty?
                    peer_groups.delete(peer_group.dejima_tables) 
                else
                    updated_group.update_peers(new_group)
                    peer_groups[peer_group.dejima_tables] = updated_group
                end
            end
        end
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
        # peer group result example
        #[ShareWithInsurance, ShareWithBank]: {attributes: [first_name, last_name, address], peers: [network_address_peer1,network_address_peer2]}
    end

end