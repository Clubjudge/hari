require 'hari/node/queries/relation/step'
require 'hari/node/queries/relation/start'
require 'hari/node/queries/relation/runnable'
require 'hari/node/queries/relation/backend/sorted_set'

module Hari
  class Node < Entity
    module Queries
      class Relation
        include Relation::Step
        include Relation::Runnable

        attr_reader :parent, :direction, :relation, :level, :options

        def initialize(parent, direction, relation, *args)
          @parent, @direction, @relation = parent, direction, relation
          @level = parent.level + 1
          @options = {}
          args.extract_options!.each { |k, v| send k, v }

          @options[:backend] = args.first.presence || Backend::SortedSet
        end

        def backend
          options[:backend]
        end

        def calculate_limit
          options[:limit] ? (options[:limit].to_i - 1) : -1
        end

        %w(limit from step).each do |method|
          define_method method do |value|
            options[method.to_sym] = value
            self
          end
        end

        # TODO for later, filter by node type
        def types(*types)
          options[:types] = types
          self
        end

        alias :type :types

        %w(nodes_ids relations_ids nodes).each do |result_type|
          define_method result_type do
            options[:result_type] = result_type.to_sym
            self
          end

          define_method "#{result_type}!" do
            send result_type
            result
          end
        end

        alias :nids    :nodes_ids
        alias :rel_ids :relations_ids
        alias :rids    :relations_ids

        def count
          options[:result_type] = :count
          result
        end

        def start_node
          level == 1 ? parent.node : parent.start_node
        end

        def call(final = true)
          if level == 1
            backend.fetch parent.node, call_args(final)
          else
            backend.step start_node, parent.call(false), call_args(final)
          end
        end

        def call_args(final = true)
          {
            relation:  relation,
            direction: direction,
            limit:     calculate_limit,
            from:      options[:from],
            step:      options[:step],
            result:    result_type(final)
          }
        end

        def result_type(final = false)
          return :nodes_ids unless final

          options.fetch :result_type, :nodes
        end

      end
    end
  end
end
