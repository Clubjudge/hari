module Hari
  module Keys
    class List < Key
      include Collection

      def list(name)
        @name = name
        self
      end

      def list!(name)
        @name = name
        range
      end

      def [](*args)
        arg = args.first

        if args.size == 2
          range *args
        elsif arg.kind_of? Integer
          at arg
        elsif arg.kind_of? Range
          range arg.first, arg.last
        end
      end

      def first
        self[0]
      end

      def last
        self[-1]
      end

      def []=(index, member)
        Hari.redis.lset key, index, serialize(member)
      end

      def range(start = 0, stop = -1)
        desserialize Hari.redis.lrange(key, start, stop)
      end

      alias :members :range
      alias :to_a    :range

      def from(index)
        range index
      end

      def to(index)
        range 0, index
      end

      def at(index)
        desserialize Hari.redis.lindex(key, index)
      end

      alias :index :at

      def trim(start, stop)
        Hari.redis.ltrim key, start, stop
      end

      def count
        Hari.redis.llen key
      end

      alias :size :count
      alias :length :count

      def empty?
        count == 0
      end

      def one?
        count == 1
      end

      def many?
        count > 1
      end

      def include?(member)
        range.include? serialize(member)
      end

      alias :member? :include?

      def push(*members)
        Hari.redis.rpush key, serialize(members)
      end

      alias :rpush :push
      alias :add   :push

      def lpush(*members)
        Hari.redis.lpush key, serialize(members)
      end

      def <<(member)
        push member
      end

      def insert_before(pivot, member)
        Hari.redis.linsert key, :before, pivot, member
      end

      def insert_after(pivot, member)
        Hari.redis.linsert key, :after, pivot, member
      end

      alias :insert :insert_after

      def delete(member, count = 0)
        Hari.redis.lrem key, count, member
      end

      def pop
        desserialize Hari.redis.rpop(key)
      end

      alias :rpop :pop

      def shift
        desserialize Hari.redis.lpop(key)
      end

      alias :lpop :shift

    end
  end
end
