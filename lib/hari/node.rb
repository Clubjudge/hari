require 'hari/node/repository'
require 'hari/node/queries'
require 'hari/node/serialization'

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

    def generate_id
      unless model_id.present?
        self.model_id = SecureRandom.hex(6)
      end

      "#{node_type}##{model_id}"
    end

    def node_type
      @node_type || self.class.node_type
    end

    def self.node_type
      self.to_s.underscore
    end

  end
end
