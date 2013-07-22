module Hari
  class Node < Entity
    module Queries
      class Relationship
        include Step
        include Runnable

        attr_reader :parent, :direction, :relation, :level, :options

        def initialize(parent, direction, relation, *args)
          @parent, @direction, @relation = parent, direction, relation
          @level = parent.level + 1
          @options = {}
          args.extract_options!.each { |k, v| send k, v }

          @options[:backend] = args.first.presence || :sorted_set
        end

        def backend
          options[:backend]
        end

        def result_type(result = false)
          return :nodes_ids unless result

          options.fetch :result_type, :nodes
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

        alias type types

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

        alias nids    nodes_ids
        alias rel_ids relations_ids
        alias rids    relations_ids

        def count
          options[:result_type] = :count
          result
        end

        def script(result, s = Script.new)
          @script ||= begin
            parent.script(false, s)
            s.import 'utils/map', 'utils/split'
            s.import "relationship/#{options[:backend]}_fetcher"
            s.import "relationship/#{options[:backend]}_merge" if level > 1
            s.import! 'relationship', index: level, result: result,
              result_type: result_type(result), backend: backend
            s.increment_args 7
          end
        end

        def script_args(result = false)
          parent.script_args + [
            relation,
            direction,
            calculate_limit,
            options.fetch(:from, ''),
            options.fetch(:step, 5),
            result_type(result),
            (result ? 1 : 0)
          ].map(&:to_s)
        end

      end
    end
  end
end
