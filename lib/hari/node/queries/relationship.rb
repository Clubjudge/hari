module Hari
  class Node < Entity
    module Queries
      class Relationship
        include Step
        include Runnable

        attr_reader :parent, :direction, :relation, :options

        def initialize(parent, direction, relation, *args)
          @parent, @direction, @relation = parent, direction, relation
          @options = {}
          args.extract_options!.each { |k, v| send k, v }

          @options[:backend] = args.first.presence || :sorted_set
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
        %w(nodes_ids relations_ids).each do |result_type|
          define_method result_type do
            options[:result_type] = result_type.to_sym
            self
          end
        end

        alias nids    nodes_ids
        alias rel_ids relations_ids
        alias rids    relations_ids

        # TODO for later, a type resolver (?) that will bring also other related
        def rollup
          options[:rollup] = true
          self
        end

        def script(s = Script.new)
          @script ||= begin
            parent.script(s)
            s.import 'utils/map', 'utils/split'
            s.import "relationship/#{options[:backend]}_fetcher"
            s.import! 'relationship'
            s.increment_args 5
          end
        end

        def script_args
          [
            options[:relation],
            options[:direction],
            options.fetch(:limit, -1),
            options.fetch(:skip, 0),
            options.fetch(:step, 5)
          ]
        end

      end
    end
  end
end
