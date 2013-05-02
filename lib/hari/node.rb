require 'hari/node/queries'

module Hari
  class Node < Entity
    include Hari::Node::Queries

    property :model_id, required: true

    def generate_id
      return model_id if model_id.include?('#')

      self.class.to_s.underscore + "#" + model_id.to_s
    end

  end
end
