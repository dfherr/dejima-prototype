class DejimaController < ApplicationController

  def initialize
    super
    @mutex = Mutex.new
  end

  # response
  def detect
    # needs to be synchronized to avoid race conditions
    @mutex.synchronize do
      puts "Magic happening"
      bases = DejimaUtils.identify_bases(params["values"])
      local_peer_groups = DejimaUtils.check_local_peer_groups(bases)
      binding.pry
    end
    render json: "hi there buddy"
  end

end