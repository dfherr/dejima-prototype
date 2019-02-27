require 'set'
require 'rest-client'

module DejimaClient

    def self.send_peer_group_request(peers, payload)
        responses = {}
        peers.each do |peer|
            begin
                response = RestClient.post("#{peer}:3000/dejima/detect", payload)
                puts "Peer #{peer} responsed: #{response}"
                binding.pry
                responses[peer] = JSON.parse response.body
            rescue RestClient::ExceptionWithResponse => e
                puts "RestClient Error response: #{e.response}"
            rescue SocketError => e
                puts "Couldn't open socket to peer #{peer}: #{e}"
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