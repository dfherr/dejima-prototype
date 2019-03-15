require 'set'
require 'rest-client'

module DejimaProxy

    def self.send_peer_group_request(peers, payload)
        Rails.logger.info("Sending peer group request.\n Peers: #{peers}\n Payload: #{payload}")
        responses = {}
        peers.each do |peer|
            begin
                response = RestClient.post("#{peer}:3000/dejima/detect", payload)
                Rails.logger.info "Peer #{peer} responded: #{response}"
                responses[peer] = JSON.parse response.body
            rescue RestClient::ExceptionWithResponse => e
                Rails.logger.warn "RestClient Error response: #{e.response}"
            rescue SocketError => e
                Rails.logger.warn "Couldn't open socket to peer #{peer}: #{e}"
            end
        end
        responses
    end

    def self.send_update_dejima_table(payload)
        peers = ["dejima-gov-peer.dejima-net"]
        binding.pry
        Rails.logger.info("Sending updates for remote dejima tables.\n Peers: #{peers}\n Payload: #{payload}")
        responses = {}
        peers.each do |peer|
            begin
                response = RestClient.post("#{peer}:3000/dejima/update_dejima_table", payload)
                Rails.logger.info "Peer #{peer} responded: #{response}"
                responses[peer] = JSON.parse response.body
            rescue RestClient::ExceptionWithResponse => e
                Rails.logger.warn "RestClient Error response: #{e.response}"
            rescue SocketError => e
                Rails.logger.warn "Couldn't open socket to peer #{peer}: #{e}"
            end
        end
        responses
    end
end


# detecting from bank to government
# request: { values: [:first_name, :last_name, :address, :phone], peers: ['government', 'bank']}

# response: [{ values: [:first_name, :last_name, :address], peers: ['government', 'bank', 'insurance']},
#           { values: [:phone], peers: ['government', 'bank']}]

# detecting from goverment to bank
# request1: { values: [:first_name, :last_name, :address], peers: ['government', 'bank', 'insurance']}
# request2: { values: [:phone], peers: ['government', 'bank']}