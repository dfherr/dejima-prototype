module DejimaManager
  # called by config/initializers/dejima_create_peer_groups.rb on startup
  def self.create_peer_groups(*models)
    # when creating we begin with all locally known peer groups
    PeerGroups.update check_local_peer_groups(models)
    Rails.logger.info "Peers groups: #{PeerGroups.get}"
    #detect_peer_groups  called by a job after server listenes
  end

  # compares remote peer groups to the locally known peer groups
  # returns all local groups that have shared Dejima tables with a remote peer group,
  # i.e. the set intersection is not empty
  #
  # this is used for responding to peer detection requests and detecting conflicts in peer group updates
  # the requesting peer gets all groups relevant for him, because dependent Dejima tables
  # are either already in the same peer group or in another peer group, that is a super or subset.
  def self.compare_remote_peer_groups(remote_peer_groups)
    found_groups = Set.new
    remote_peer_groups.each do |remote_peer_group|
      PeerGroups.get.each_value do |peer_group|
       # binding.pry
        found_groups << peer_group if peer_group.dejima_tables.intersect? remote_peer_group.dejima_tables
      end
    end
    found_groups
  end

  # tries to detect other peer groups in the network based on the locally known peer groups
  def self.detect_peer_groups
    # now we start the network traversal
    peers_visited = Set.new([Rails.application.config.peer_network_address])
    loop do
      peers = {}

      # map peer addresses to peer_groups connected to this peer
      PeerGroups.get.each_value do |peer_group|
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
          PeerGroups.add_new_peer_group peer_group
        end
      end
    end

    Rails.logger.info "Detected peer groups: #{PeerGroups.get}"
    self.broadcast_peer_groups
  end

  # sends updated peer groups to all relevant peers
  def self.broadcast_peer_groups
    Metric.get_current.increment!(:broadcast_count)
    Metric.get_current.update!(last_broadcast: Time.now)
    Rails.logger.info "Broadcasting new peer groups"
    peer_groups_per_peer = {}
    PeerGroups.get.each_value do |peer_group|
      peer_group.peers.each do |peer|
        peer_groups_per_peer[peer] ||= Set.new
        peer_groups_per_peer[peer] << peer_group
      end
    end
    peer_groups_per_peer.each do |peer, peer_groups|
      DejimaProxy.send_peer_group_update(peer, peer_groups.to_a) unless peer == Rails.application.config.peer_network_address
    end
  end

  # adds remote peer groups to local groups
  def self.add_remote_peer_groups(remote_peer_groups)
    # detect possible conflicts from race conditions
    # we might have updated peer groups after responding to the peer group request
    # that leads to this update request. So some relevant peers might've been missing
    #
    # We detect that by comparing the sets of all relevant locally known peers and
    # all peers in this update request. If we know peers that are not in the update 
    # request, we need to initiate a broadcast ourselfs.
    possible_conflict_groups = compare_remote_peer_groups(remote_peer_groups)
    
    locally_known_peers = Set.new
    possible_conflict_groups.each do |peer_group|
      locally_known_peers.union peer_group.peers
    end
    remotely_known_peers = Set.new
    remote_peer_groups.each do |peer_group|
      remotely_known_peers.union peer_group.peers
    end
    conflict = !(locally_known_peers - remotely_known_peers).empty?
    
    # now add all remote peer groups to the local peer groups
    remote_peer_groups.each do |peer_group|
      PeerGroups.add_new_peer_group peer_group
    end
    Rails.logger.info "Updated peer groups: #{PeerGroups.get.values.to_json}"
    # broadcast if we detected a conflict
    if conflict
      Rails.logger.info "Initiating broadcast to resolve conflicts."
      Metric.get_current.increment!(update_request_conflict_count)
      broadcast_peer_groups
    end

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
    peer_groups = {}
    attribute_to_dejima_tables.each_pair do |attribute, dejima_tables|
      peer_group = peer_groups[dejima_tables] || PeerGroup.new(dejima_tables: dejima_tables)
      peer_group.attributes << attribute[1]
      dejima_tables.each do |dejima_table|
        peer_group.peers = peer_group.peers.union tables_to_peers[dejima_table]
      end
      peer_groups[dejima_tables] = peer_group
    end
    peer_groups
  end
end
