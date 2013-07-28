module Hari
  class Relation < Entity
    module LinkedList
      extend self

      def create(rel)
        Relation::DIRECTIONS.each { |d| Hari.redis.lpush rel.key(d), rel.id }
      end

      def delete(rel)
        Relation::DIRECTIONS.each { |d| Hari.redis.lrem rel.key(d), 1, rel.id }
      end

    end
  end
end
