require 'hari/node/repository'
require 'hari/node/queries'
require 'hari/node/serialization'
require 'hari/node/index'

module Hari
  class Node < Entity
    include Hari::Node::Queries
    include Hari::Node::Repository
    extend  Hari::Node::Serialization

    property :model_id

    def initialize(attrs = {})
      attrs = { model_id: attrs } if attrs.kind_of?(::Fixnum)
      super
    end

    after_save    { reindex }
    after_destroy { remove_from_indexes }

    def generate_id
      unless model_id.present?
        begin
          self.model_id = SecureRandom.hex(8)
        end until !Hari.redis.exists(node_key)
      end

      node_key
    end

    def node_key
      "#{node_type}##{model_id}"
    end

    def node_type
      @node_type || self.class.node_type
    end

    def self.node_type
      self.to_s.underscore
    end

    def self.indexed_properties
      properties.select { |p| p.options[:index] }
    end

  end
end
