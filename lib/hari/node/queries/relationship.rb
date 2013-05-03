module Hari
  class Node < Entity
    module Queries
      class Relationship
        include Step
        include Runnable

        attr_reader :parent, :direction, :relation, :options

        def initialize(parent, direction, relation, options = {})
          @parent, @direction, @relation = parent, direction, relation
          @options = {}
          options.each { |k, v| send k, v }
        end

        %w(limit skip step).each do |method|
          define_method method do |value|
            options[method.to_sym] = value
            self
          end
        end

        # TODO also have a custom type resolver that could bring moar complex stuff
        %w(nodes_ids relations_ids).each do |result_type|
          define_method result_type do
            options[:result_type] = result_type.to_sym
            self
          end
        end

        alias nids    nodes_ids
        alias rel_ids relations_ids
        alias rids    relations_ids

        def types(*types)
          options[:types] = types
          self
        end

        alias type types

      end
    end
  end
end
