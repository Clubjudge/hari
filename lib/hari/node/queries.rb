require 'hari/node/queries/relation'
require 'hari/node/queries/type'

module Hari
  class Node < Entity
    module Queries
      extend ActiveSupport::Concern

      delegate :in, :out, to: :relation_query

      Keys::TYPES.each do |key|
        query_builder = Keys.const_get(key.camelize)

        define_method key do |name = nil, options = {}|
          return super() unless name

          query = query_builder.new(query_node, options)
          query.send key, name
        end

        define_method "#{key}!" do |name, options = {}|
          query = query_builder.new(query_node, options)
          query.send "#{key}!", name
        end
      end

      included do
        Keys::TYPES.each do |key|
          define_singleton_method key do |name = nil, options = {}|
            return super() unless name

            define_method(name) { send key, name, options }
            define_method("#{name}!") { send "#{key}!", name, options }

            define_method "#{name}=" do |value|
              data = send(name)
              data.delete!

              data.add *value
            end
          end
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
