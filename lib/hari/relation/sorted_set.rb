module Hari
  class Relation < Entity
    module SortedSet
      extend self

      def create(relation)
        Relation::DIRECTIONS.each do |direction|
          key    = relation.key(direction)
          weight = relation.weight(direction)

          Hari.redis.zadd key, weight, relation.id
          Hari.redis.zadd type_key(relation, direction), weight, type_id(relation, direction)
        end
      end

      def delete(relation)
        Relation::DIRECTIONS.each do |direction|
          key = relation.key(direction)

          Hari.redis.zrem key, relation.id
          Hari.redis.zrem type_key(relation, direction), type_id(relation, direction)
        end
      end

      private

      def type_key(relation, direction)
        case direction.to_s
        when 'out'
          "#{relation.start_node_id}:#{relation.label}:out:#{Hari.node_type(relation.end_node_id)}"
        when 'in'
          "#{relation.end_node_id}:#{relation.label}:in:#{Hari.node_type(relation.start_node_id)}"
        end
      end

      def type_id(relation, direction)
        case direction.to_s
        when 'in'  then Hari.node_id(relation.start_node_id)
        when 'out' then Hari.node_id(relation.end_node_id)
        end
      end

    end
  end
end
