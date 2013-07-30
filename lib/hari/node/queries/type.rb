module Hari
  class Node < Entity
    module Queries
      class Type

        attr_reader :relation, :name

        def initialize(relation, name)
          @relation, @name = relation, name
        end

        def intersect_count(type)
          Hari.redis.zcard interstore(type)
        end

        def intersect(type, start = nil, stop = nil)
          start ||= 0
          stop  ||= -1
          Hari.redis.zrevrange interstore(type), start, stop
        end

        def interstore(type)
          destination = intersect_key(type)
          Hari.redis.zinterstore destination, [key, type.key]
          destination
        end

        def key
          start_key = Hari.node_key(relation.parent.node)
          "#{start_key}:#{relation.name}:#{relation.direction}:#{name}"
        end

        def intersect_key(type)
          "inter:#{key}:#{type.key}"
        end

      end
    end
  end
end
