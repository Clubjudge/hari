require 'hari/relationship/linked_list'
require 'hari/relationship/sorted_set'

module Hari
  class Relationship < Entity

    properties :label, :start_node_id, :end_node_id, presence: true

    def start_node
      @start_node ||= Hari::Node.find(start_node_id)
    end

    def end_node
      @end_node ||= Hari::Node.find(end_node_id)
    end

    def key(direction = nil)
      case direction.try :to_s
      when nil
        "#{start_node_id}:#{label}:#{end_node_id}"
      when 'out'
        "#{start_node_id}:#{label}:out"
      when 'in'
        "#{end_node_id}:#{label}:in"
      end
    end

    def generate_id
      "rel:#{start_node_id}:#{end_node_id}:#{backend.type}:#{SecureRandom.hex(3)}"
    end

    def self.create(label, start_node, end_node, attrs = {})
      attrs = attrs.merge(label: label,
                          start_node_id: Hari.node_key(start_node),
                          end_node_id:   Hari.node_key(end_node))
      new(attrs).save
    end

    def self.use!(backend)
      @backend = backend.kind_of?(Module) ? backend
       : "Hari::Relationship::#{backend.to_s.camelize}".constantize
    end

    def self.backend
      @backend ||= Hari::Relationship::SortedSet
    end

    def backend
      self.class.backend
    end

    def weight(direction)
      ::Time.now.to_f
    end

    private

    def create
      super
      backend.create self
      Hari.redis.set key, id
      self
    end

    def delete
      backend.delete self
      Hari.redis.del key
      super
      self
    end

  end
end
