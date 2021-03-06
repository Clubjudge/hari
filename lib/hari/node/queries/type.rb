module Hari
  class Node < Entity
    module Queries
      class Type

        attr_reader :relation, :name, :options

        def initialize(relation, name)
          @relation, @name = relation, name
          @options = {}
        end

        def intersect_count(type)
          intersect_key = interstore(type)

          Hari.redis.zcard(intersect_key).tap do
            Hari.redis.del intersect_key
          end
        end

        def intersect(type, start = nil, stop = nil)
          start ||= 0
          stop  ||= -1

          intersect_key = interstore(type)

          Hari.redis.zrevrange(intersect_key, start, stop).tap do
            Hari.redis.del intersect_key
          end
        end

        def sort_by(type, offset = nil, count = nil, order = nil)
          offset ||= 0
          count  ||= Hari.redis.zcard(key)
          order  = 'desc' unless order.to_s == 'asc'

          Hari.redis.sort key, by: type.sort_key, order: "#{order} alpha", limit: [offset, count]
        end

        def interstore(type)
          intersect_key(type).tap do |destination|
            Hari.redis.zinterstore destination, [key, type.key]
          end
        end

        def count
          Hari.redis.zcard key
        end

        def ids
          start = options[:start] || 0
          stop  = options[:stop]  || -1
          from  = options[:from]
          limit = stop == -1 ? stop : stop - start + 1

          if from.present? && from[:direction] == 'up'
            Hari.redis.zrevrangebyscore key, '+inf', from[:score], limit: [start, limit]
          elsif from.present? && from[:direction] == 'down'
            Hari.redis.zrevrangebyscore key, from[:score], '-inf', limit: [start, limit]
          else
            Hari.redis.zrevrange key, start, stop
          end
        end

        def nodes_ids
          ids.map { |id| "#{name}##{id}" }
        end

        alias :nodes_ids! :nodes_ids
        alias :n_ids      :nodes_ids
        alias :nids       :nodes_ids

        def nodes
          if ids = nodes_ids.presence
            Hari.redis.mget(ids).map &Hari::Node.method(:from_source)
          else
            []
          end
        end

        alias :nodes! :nodes
        alias :to_a   :nodes

        def relations_ids
          ids.map &method(:relation_key)
        end

        alias :relations_ids! :relations_ids
        alias :rids           :relations_ids
        alias :rel_ids        :relations_ids

        def limit(start, stop)
          options.merge! start: start, stop: stop

          self
        end

        def from(score, direction = nil)
          direction ||= :up
          options[:from] = { score: score.to_f, direction: direction.to_s }

          self
        end

        def <<(ids)
          Array(ids).each do |id|
            Hari.relation! relation.name, relation.parent.node, Hari(name => id)
          end
        end

        def where(conditions = {})
          type_class.where(conditions).tap do |index|
            index.indexes << self
          end
        end

        def count_by(direction, relation, type = nil, options = {})
          key = "%s:#{relation}:#{direction}"
          key << ":#{type}" if type

          nodes_ids.inject([]) do |buffer, node_id|
            count = if options[:from].nil?
              Hari.redis.zcard(key % node_id)
            else
              Hari.redis.zcount(key % node_id, options[:from].to_f, '+inf')
            end

            buffer << [node_id, count]
          end.sort_by { |(n, c)| c }.reverse
        end

        def key
          "#{start_key}:#{relation.name}:#{relation.direction}:#{name}"
        end

        def sort_key
          relation_key '*'
        end

        def relation_key(id)
          "#{start_key}:#{relation.name}:#{name}##{id}"
        end

        def intersect_key(type)
          "inter:#{key}:#{type.key}"
        end

        def start_key
          Hari.node_key relation.parent.node
        end

        def type_class
          name.to_s.camelize.constantize
        end

      end
    end
  end
end
