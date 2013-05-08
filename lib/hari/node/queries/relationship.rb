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

        def result_type
          options.fetch :result_type, :nodes
        end

        def calculate_limit
          return -1 unless options[:limit]

          options.fetch(:skip, 0) + options[:limit] - 1
        end

        %w(limit skip step).each do |method|
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

        # TODO also have a custom type resolver that could bring moar complex stuff
        %w(nodes_ids relations_ids nodes rollup).each do |result_type|
          define_method result_type do
            options[:result_type] = result_type.to_sym
            self
          end
        end

        alias nids    nodes_ids
        alias rel_ids relations_ids
        alias rids    relations_ids

        def script(s = Script.new)
          @script ||= begin
            parent.script(s)
            s.import 'utils/map', 'utils/split'
            s.import "relationship/#{options[:backend]}_fetcher"
            s.import! 'relationship', index: level
            s.increment_args 7
          end
        end

        def script_args(result = false)
          parent.script_args + [
            relation,
            direction,
            calculate_limit,
            options.fetch(:skip, 0),
            options.fetch(:step, 5),
            result_type,
            (result ? 1 : 0)
          ].map(&:to_s)
        end

      end
    end
  end
end
