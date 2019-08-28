class DejimaController < ApplicationController
  def initialize
    super
    @mutex = Mutex.new
  end

  # respond to peer group detection
  # only available for config.prototype_role == :peer
  def detect
    Metric.get_current.increment!(:messages_received)
    raise "Only peer role can run detection" unless Rails.application.config.prototype_role == :peer
    Rails.logger.info "Responding to detection request"
    remote_peer_groups = JSON.parse(params["peer_groups"], symbolize_names: true).map(&PeerGroup.method(:new))
    render json: DejimaManager.compare_remote_peer_groups(remote_peer_groups)
  end

  # update config based on newer detection run of a peer
  # only available for config.prototype_role == :peer
  def update_peer_groups
    Metric.get_current.increment(:messages_received)
    Metric.get_current.increment(:update_request_count)
    Metric.get_current.update!(last_update_request_received: Time.now)
    Rails.logger.info "Received peer group update"
    new_peer_groups = JSON.parse(params["peer_groups"], symbolize_names: true).map(&PeerGroup.method(:new))
    DejimaManager.add_remote_peer_groups(new_peer_groups)
    render json: "success"
  end

  # only available for config.prototype_role == :peer
  # this api endpoint is used by the database
  def propagate
    params.permit!
    params_hash = params.to_h
    payload_hash = {}
    # Parameters: {"view"=>"public.dejima_bank", "insertion"=>[{"first_name"=>"John", "last_name"=>"Doe", "phone"=>nil, "address"=>nil}], "deletion"=>[]}
    payload_hash[:view] = params_hash["view"]
    payload_hash[:insertions] = params_hash["insertions"]
    payload_hash[:deletions] = params_hash["deletions"]
    DejimaProxy.send_update_dejima_table(payload_hash)
    render json: "true"
  end

  # only available for config.prototype_role == :peer
  def update_dejima_table
    sql_statements = []
    params["insertions"].each do |insert|
      sql_columns = "("
      sql_values = "("
      insert.each do |column, value|
        sql_columns += "#{column}, "
        sql_values += if value.nil?
                        "NULL, "
                      else
                        "'#{value}', "
                      end
      end
      sql_columns = sql_columns[0..-3] + ")"
      sql_values = sql_values[0..-3] + ")"
      sql_statements << "INSERT INTO #{params['view']} #{sql_columns} VALUES #{sql_values};"
    end
    Rails.logger.info("Updating dejima table #{params['view']} with statements:\n#{sql_statements.join("\n")}")
    ActiveRecord::Base.connection.execute(sql_statements.join("\n"))
    render json: "true"
  end

  # only available for config.prototype_role == :client
  def create_user
    first_name = params["first_name"] || "John"
    last_name = params["last_name"] || "Doe"
    BankUser.create(first_name: first_name, last_name: last_name)
  end
end
