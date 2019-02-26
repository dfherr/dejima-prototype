class DejimaController < ApplicationController

  def initialize
    super
    @mutex = Mutex.new
  end

  # respond to peer group detection
  def detect
    # needs to be synchronized to avoid race conditions on 
    # multiple peers initilizing at the same time

    @mutex.synchronize do
      puts "Magic happening"
      dejima_tables = Set.new(params["dejima_tables"])
      peers = Set.new(params["peers"])
      bases = DejimaUtils.identify_bases(dejima_tables)
      local_peer_groups = DejimaUtils.check_local_peer_groups(bases)
      respond = [] # response is used by rails :)  
      local_peer_groups.each do |tables, values|
        # respond if we found tables that are a proper superset (not euqal) or if we know peers not yet known
        if tables.proper_superset?(dejima_tables) || !values[:peers].subtract(peers).empty?
          payload = {}
          payload[:dejima_tables] = tables.to_a
          payload[:attributes] = values[:attributes].to_a
          payload[:peers] = values[:peers].to_a
          respond << payload
        end
      end
      binding.pry
      if respond.empty?
        render json: "ok"
      else
        render json: respond
      end
    end
  end

  # update config based on newer detection run of a peer
  def update

  end

end