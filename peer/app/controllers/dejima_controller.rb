class DejimaController < ApplicationController

  def initialize
    super
    @mutex = Mutex.new
  end

  # respond to peer group detection
  # only available for config.prototype_role == :peer
  def detect
    raise "Only peer role can run detection" unless Rails.application.config.prototype_role == :peer

    # needs to be synchronized to avoid race conditions on 
    # multiple peers initilizing at the same time
    # this mutex might be redundant, because we are running in single server mode and 
    # it would not work in multi-worker mode as it's not shared across processes, but
    # it illustrates the concept
    @mutex.synchronize do
      Rails.logger.info "Responding to detection request"
      dejima_tables = Set.new(params["dejima_tables"])
      peers = Set.new(params["peers"])
      bases = DejimaUtils.identify_bases(dejima_tables)
      local_peer_groups = DejimaUtils.check_local_peer_groups(bases)
      respond = [] # response is used by rails :)  
      local_peer_groups.each do |tables, values|
        # respond if we found tables that are a proper superset (not euqal) or if we know peers not yet known
        # in the first case the requesting peer needs to be informed about another dejima group needing this data
        # in the second case there exist more peers needing the data than the requester knew about
        if tables.proper_superset?(dejima_tables) || !values[:peers].subtract(peers).empty?
          payload = {}
          payload[:dejima_tables] = tables.to_a
          payload[:attributes] = values[:attributes].to_a
          payload[:peers] = values[:peers].to_a
          respond << payload
        end
      end
      if respond.empty?
        Rails.logger.info "Detected no required updates to request. Ok!"
        render json: JSON.generate("ok")
      else
        Rails.logger.info "Detected necessary updates:\n #{JSON.pretty_generate(respond)}"
        render json: JSON.generate(respond)
      end
    end
  end

  # update config based on newer detection run of a peer
  # only available for config.prototype_role == :peer
  def update_peers

  end

  # only available for config.prototype_role == :peer
  def propagate
    Rails.logger.info "Propagate:\n #{params}"
    DejimaProxy.send_update_dejima_table("test")
    render text: "true"
  end

  # only available for config.prototype_role == :peer
  def update_dejima_table
    Rails.logger.info "Update dejima table:\n #{params}"
    ActiveRecord::Base.connection.execute("INSERT INTO dejima_bank (first_name, last_name) VALUES ('John', 'Doe');")
    Rails.logger.info "unlocking update"
    render text: "true"
  end

  # only available for config.prototype_role == :client
  def create_user
    first_name = params["first_name"] || "John"
    last_name = params["last_name"] || "Doe"
    BankUser.create(first_name: first_name, last_name: last_name)
  end

end