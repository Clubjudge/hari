module Hari
  class Node < Entity
    module Queries
      class Type

        attr_reader :relation, :name

        def initialize(relation, name)
          @relation, @name = relation, name
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

        def key
          start_key = Hari.node_key(relation.parent.node)
          "#{start_key}:#{relation.name}:#{relation.direction}:#{name}"
        end

        def sort_key
          start_key = Hari.node_key(relation.parent.node)
          "#{start_key}:#{relation.name}:#{name}#*"
        end

        def intersect_key(type)
          "inter:#{key}:#{type.key}"
        end

      end
    end
  end
end
