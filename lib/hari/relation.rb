require 'hari/relation/sorted_set'

module Hari
  #
  # Has a relation from one {Hari::Node} to another
  #
  class Relation < Entity

    DIRECTIONS = %w(in out)

    attr_accessor :label, :start_node_id, :end_node_id, :default_weight

    validates :label, :start_node_id, :end_node_id, presence: true

    # @return [Hari::Node]
    #
    def start_node
      @start_node ||= Hari::Node.find(start_node_id)
    end

    # @return [Hari::Node]
    #
    def end_node
      @end_node ||= Hari::Node.find(end_node_id)
    end

    # Returns, depending on direction, the relation key
    #
    # @param direction [nil, #to_s]
    #           when 'in', brings index key for all end_node ins
    #           when 'out', brings index key for all start_node outs
    #           else, brings the relation key itself.
    #
    # @return [String]
    #
    def key(direction = nil)
      case direction.try :to_s
      when nil   then "#{start_node_id}:#{label}:#{end_node_id}"
      when 'out' then "#{start_node_id}:#{label}:out"
      when 'in'  then "#{end_node_id}:#{label}:in"
      end
    end

    alias :generate_id :key

    # Creates a Relation between two nodes
    #
    # @param label [#to_s] relation name
    # @param start_node [Hari::Node, String, Hash]
    # @param end_node [Hari::Node, String, Hash]
    # @param attrs [Hash] { weight (default: Time.now.to_f) }
    #
    # @return [Hari::Relation]
    #
    def self.create(label, start_node, end_node, attrs = {})
      new(attrs).tap do |r|
        r.label = label
        r.start_node_id  = Hari.node_key(start_node)
        r.end_node_id    = Hari.node_key(end_node)
        r.default_weight = attrs.delete(:weight)
        r.save
      end
    end

    def self.use!(backend)
      @backend = backend.kind_of?(Module) ? backend
       : "Hari::Relation::#{backend.to_s.camelize}".constantize
    end

    def self.backend
      @backend ||= Hari::Relation::SortedSet
    end

    def backend
      self.class.backend
    end

    def weight(direction)
      default_weight.try(:to_f) || ::Time.now.to_f
    end

    def create
      super
      backend.create self
      self
    end

    def delete
      backend.delete self
      super
      self
    end

  end
end
