module Hari
  class Relationship < Entity
    module Backend
      module LinkedList
        extend self

        def type
          :ll
        end

        def create(rel)
          %w(in out).each { |d| Hari.redis.lpush rel.key(d), rel.id }
        end

        def delete(rel)
          %w(in out).each { |d| Hari.redis.lrem rel.key(d), 1, rel.id }
        end

      end
    end
  end
end
