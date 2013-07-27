class Hari::Node::Queries::Relation
  module Backend
    module SortedSet
      extend self

      def fetch(node, options = {})
        set = node.sorted_set set_name(options)
        send "fetch_#{options[:result]}", set, options
      end

      def fetch_relations_ids(set, options)
        from, limit = options.values_at(:from, :limit)

        if from.present?
          set.range_by_score from, '+inf', desc: true, limit: [0, limit]
        else
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

      def step(start_node, nodes_ids, options = {})
        stream    = start_node.sorted_set("stream:#{SecureRandom.hex(6)}")
        direction = options[:direction] == :in ? 0 : 2
        limit     = options.fetch(:limit, -1)

        nodes_ids.each_with_index do |node_id, index|
          prune, stop = true, options.fetch(:step, 5)

          if limit == -1 || stream.count < limit
            prune, stop = false, limit
          end

          start, digg = 0, true

          while digg
            set = Hari(node_id).sorted_set set_name(options)

            if from = options[:from].presence
              scored_relations_ids = set.range_by_score(from, '+inf', desc: true, with_scores: true, limit: [start, stop])
            else
              scored_relations_ids = set.range(start, stop, desc: true, with_scores: true)
            end

            break if scored_relations_ids.empty?

            scored_nodes_ids = scored_relations_ids.map { |(r, s)| [s, r.split(':')[direction]] }.flatten
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
        end

        nodes_ids = stream.revrange

        if nodes_ids.any? && options[:result] == :nodes
          Hari.redis.mget nodes_ids
        else
          nodes_ids
        end
      end

      private

      def set_name(options)
        "#{options[:relation]}:#{options[:direction]}"
      end

    end
  end
end
