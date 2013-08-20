require 'hari/node/queries/relation'
require 'hari/node/queries/type'

module Hari
  class Node < Entity
    module Queries

      delegate :in, :out, to: :relation_query

      %w(string hash list set sorted_set).each do |key|
        query_builder = Keys.const_get(key.camelize)

        define_method key do |name = nil, options = {}|
          super() unless name
          query = query_builder.new(query_node, options)
          query.send key, name
        end

        define_method "#{key}!" do |name, options = {}|
          query = query_builder.new(query_node, options)
          query.send "#{key}!", name
        end
      end

      private

      def relation_query
        Queries::Relation::Start.new query_node
      end

      def query_node
        self.kind_of?(Hari::Node) ? self : nil
      end

    end
  end
end
