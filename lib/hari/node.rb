require 'hari/node/queries'

module Hari
  class Node < Entity
    include Hari::Node::Queries

    property :model_id

    def generate_id
      case model_id
      when nil
        super
      when model_id.to_s.include?('#')
        model_id
      else
        self.class.to_s.underscore + "#" + model_id.to_s
      end
    end

  end
end
