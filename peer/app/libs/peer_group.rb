class PeerGroup
  attr_accessor :dejima_tables,
                :peers,
                :attributes

  def initialize(dejima_tables:, peers: nil, attributes: nil)
    # dejima_tables might be initialized with classes or strings from json responses.
    # old switcheroo solves that
    @dejima_tables = Set.new dejima_tables.map(&:to_s).map(&:constantize)
    @peers = Set.new peers
    @attributes = Set.new attributes
  end

  def as_json(opts={})
    {
      dejima_tables: dejima_tables.to_a.map(&:to_s),
      peers: peers.to_a,
      attributes: attributes.to_a
    }
  end
end