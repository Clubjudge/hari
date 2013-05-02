module Hari
  class Relationship < Entity
    module Backend
      module SortedSet
        extend self

        def type
          :ss
        end

        def create(rel)
          %w(in out).each { |d| Hari.redis.zadd rel.key(d), rel.weight(d), rel.id }
        end

        def delete(rel)
          %w(in out).each { |d| Hari.redis.zrem rel.key(d), rel.id }
        end

      end
    end
  end
end
