require 'hari/node/repository'
require 'hari/node/queries'
require 'hari/node/serialization'
require 'hari/node/index'

module Hari
  #
  # Nodes can persist its properties, if any,
  # in a Redis string via JSON.
  #
  # Nodes can also index its properties for
  # further search.
  #
  # Nodes can have relationship with other
  # Hari Objects, like other Redis structures
  # (string, lists, sets, sorted sets)
  # (see {Hari::Node::Queries}), or
  # a {Hari::Relation} with other nodes.
  #
  class Node < Entity
    include Hari::Node::Queries
    include Hari::Node::Repository
    extend  Hari::Node::Serialization

    property :model_id

    def initialize(attrs = {})
      attrs = { model_id: attrs } if attrs.kind_of?(::Fixnum)
      super
    end

    after_update  { reindex }
    after_create  { reindex force_index: true }
    after_destroy { remove_from_indexes }

    # Generates an id for a newborn node.
    #
    # Makes sure there's not a node in Redis
    # with the same id.
    #
    # @return [String]
    #
    def generate_id
      unless model_id.present?
        begin
          self.model_id = SecureRandom.hex(8)
        end until !Hari.redis.exists(node_key)
      end

      node_key
    end

    # @return [String] the node representation, type#id
    #
    def node_key
      "#{node_type}##{model_id}"
    end

    # @return [String]
    #
    def node_type
      @node_type || self.class.node_type
    end

    # @param [#to_s]
    # @return [String]
    #
    def self.node_type=(type)
      @node_type = type.to_s
    end

    # Returns the class name
    # (default node type for its instances)
    #
    # @return [String]
    #
    def self.node_type
      @node_type || self.to_s.underscore
    end

    # Sets the node type
    #
    # @param type [#to_s]
    #
    def self.node_type=(type)
      @node_type = type.to_s.underscore
    end

    # Returns the properties where index: true
    #
    # @return [Array<Hari::Entity::Property>]
    #
    def self.indexed_properties
      properties.select { |p| p.options[:index] }
    end

  end
end
