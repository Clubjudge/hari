require 'hari/node/queries/relation/backend/sorted_set/node_step'
require 'hari/node/queries/relation/backend/sorted_set/count_step'

module Hari::Node::Queries
  class Relation
    module Backend
      module SortedSet
        extend self
        extend SortedSet::NodeStep
        extend SortedSet::CountStep

        def fetch(node, options = {})
          set = node.sorted_set set_name(options)
          send "fetch_#{options[:result]}", set, options
        end

        def fetch_relations_ids(set, options)
          from, limit = options.values_at(:from, :limit)
          limit = limit.try(:to_i)

          if from.present? && from[:direction] == 'up'
            set.range_by_score "(#{from[:score]}", '+inf', desc: true, limit: [0, limit]
          elsif from.present? && from[:direction] == 'down'
            set.range_by_score '-inf', "(#{from[:score]}", desc: true, limit: [0, limit]
          else
            limit -= 1 unless limit <= 0
            set.range from, limit, desc: true
          end
        end

        def fetch_nodes_ids(set, options)
          index = set.name =~ /in$/ ? 0 : 2
          fetch_relations_ids(set, options).map { |r| r.split(':')[index] }
        end

        def fetch_nodes(set, options)
          nodes_ids = fetch_nodes_ids(set, options)
          nodes_ids.empty? ? [] : Hari.redis.mget(nodes_ids)
        end

        def fetch_count(set, options)
          set.count
        end

        def step(start_node, nodes_ids, options)
          send "step_#{options[:result]}", start_node, nodes_ids, options
        end

        def set_name(options)
          "#{options[:relation]}:#{options[:direction]}"
        end

      end
    end
  end
end
