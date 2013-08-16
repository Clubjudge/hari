module Hari::Node::Queries
  class Relation
    module Backend
      module SortedSet
        module NodeStep

          def step_nodes(start_node, nodes_ids, options)
            stream = start_node.sorted_set("stream:#{SecureRandom.hex(6)}")

            nodes_ids.each { |node_id| step_node node_id, stream, options }

            ids = stream.revrange

            stream.delete!

            case options[:result]
            when :nodes_ids
              ids
            when :nodes
              ids.any? ? Hari.redis.mget(ids) : []
            end
          end

          alias :step_nodes_ids :step_nodes

          def step_node(node_id, stream, options)
            set = Hari(node_id).sorted_set set_name(options)

            start = 0
            stop = calculate_stop(stream, options)
            prune = stream.count > options[:limit] && options[:limit] != -1

            digg = true

            while digg
              if from = options[:from].presence
                args = { desc: true, with_scores: true, limit: [start, stop] }

                if from[:direction] == 'up'
                  scored_relations_ids = set.range_by_score(from[:score], '+inf', args)
                elsif from[:direction] == 'down'
                  scored_relations_ids = set.range_by_score('-inf', from[:score], args)
                end
              else
                scored_relations_ids = set.range(start, stop, desc: true, with_scores: true)
              end

              break if scored_relations_ids.empty?

              scored_nodes_ids = scored_relations_ids.map { |(r, s)| [s, r.split(':')[options[:position]]] }.flatten
              stream.add *scored_nodes_ids

              last_node_id = scored_nodes_ids.last

              if prune
                stream.trim_by_rank 0, stop

                unless stream.include? last_node_id
                  digg = false
                  start += stop + 1
                end
              else
                digg = false
              end
            end

            stream_count = stream.count

            if options[:limit] != -1 && stream_count > options[:limit]
              trim_stop = stream_count - options[:limit] - 1
              stream.trim_by_rank 0, trim_stop
            end
          end

          def calculate_stop(stream, options)
            return options[:step].to_i if options[:step].present?
            return options[:limit] if stream.count < options[:limit]

            case options[:limit]
            when -1, 1...5
              options[:limit]
            else
              5
            end
          end

        end
      end
    end
  end
end
