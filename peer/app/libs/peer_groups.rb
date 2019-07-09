require 'singleton'

class PeerGroups
  include Singleton

  def groups
    @peer_groups ||= {}
  end

end