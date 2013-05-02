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

    def key(dir = nil)
      case dir
      when nil
        "#{start_node_id}:#{label}:#{end_node_id}"
      else
        "#{start_node_id}:#{label}:#{dir}"
      end
    end

    def generate_id
      "rel:#{start_node.id}:#{end_node.id}:#{backend.type}:#{SecureRandom.hex(3)}"
    end

    def self.create(label, start_node, end_node, attributes = {})
      attrs = attributes.merge(label: label,
                               start_node_id: node_id(start_node),
                               end_node_id: node_id(end_node))
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

    def weight(dir)
      ::Time.now.to_f
    end

    private

    def self.node_id(node)
      node.kind_of?(::String) ? node : node.try(:id)
    end

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
