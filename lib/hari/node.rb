require 'hari/node/queries/step'
require 'hari/node/queries/start'
require 'hari/node/queries/runnable'
require 'hari/node/queries/relationship'
require 'hari/node/queries'

module Hari
  class Node < Entity
    include Hari::Node::Queries

    property :model_id

    def initialize(attrs = {})
      attrs = { model_id: attrs } if attrs.kind_of?(::Fixnum)
      super
    end

    def generate_id
      return super unless model_id

      model_id.to_s.include?('#') ? model_id.to_s : "#{node_type}##{model_id}"
    end

    def node_type
      self.class.to_s.underscore
    end

  end
end
