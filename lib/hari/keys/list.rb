module Hari
  module Keys
    #
    # Enables Redis Lists in Hari.
    # Lists are simply lists of strings, sorted by insertion order.
    #
    # @see http://redis.io/commands#list
    #
    class List < Key
      include Collection

      # Sets lists name
      #
      # @return [self]
      #
      def list(name)
        @name = name
        self
      end

      # Sets list name and retrieves its members
      #
      # @return [Array<Object>]
      #
      def list!(name)
        list(name).members
      end

      # @see http://redis.io/commands/lindex
      # @see http://redis.io/commands/lrange
      #
      # @return [Object, Array<Object>]
      #
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

      # @see http://redis.io/commands/lindex
      #
      # @return [Object]
      #
      def first
        self[0]
      end

      # @see http://redis.io/commands/lindex
      #
      # @return [Object]
      #
      def last
        self[-1]
      end

      # @see http://redis.io/commands/lset
      #
      # @return ['OK']
      #
      def []=(index, member)
        redis.lset key, index, serialize(member)
      end

      # @see http://redis.io/commands/lrange
      #
      # @return [Array<Object>]
      #
      def range(start = 0, stop = -1)
        desserialize redis.lrange(key, start, stop)
      end

      alias :members :range
      alias :to_a    :range

      # @see http://redis.io/commands/lrange
      #
      # @return [Array<Object>]
      #
      def from(index)
        range index
      end

      # @see http://redis.io/commands/lrange
      #
      # @return [Array<Object>]
      #
      def to(index)
        range 0, index
      end

      # @see http://redis.io/commands/lindex
      #
      # @return [Object, nil]
      #
      def at(index)
        desserialize redis.lindex(key, index)
      end

      alias :index :at

      # @see http://redis.io/commands/ltrim
      #
      # @return ['OK']
      #
      def trim(start, stop)
        redis.ltrim key, start, stop
      end

      # @see http://redis.io/commands/llen
      #
      # @return [Fixnum]
      #
      def size
        redis.llen key
      end

      alias :length :size

      # @see http://redis.io/commands/lrange
      #
      # @return [true, false]
      #
      def include?(member)
        range.include? serialize(member)
      end

      alias :member? :include?

      # @see http://redis.io/commands/rpush
      #
      # @return [Fixnum, nil] list length after operation
      #
      def push(*members)
        return if Array(members).empty?

        redis.rpush key, serialize(members)
      end

      alias :rpush :push
      alias :add   :push

      # @see http://redis.io/commands/lpush
      #
      # @return [Fixnum] list length after operation
      #
      def lpush(*members)
        redis.lpush key, serialize(members)
      end

      # @see http://redis.io/commands/rpush
      #
      # @return [Fixnum, nil] list length after operation
      #
      def <<(member)
        push member
      end

      # @see http://redis.io/commands/linsert
      #
      # @return [Fixnum] list length after operation
      #                  or -1 if pivot was not found
      #
      def insert_before(pivot, member)
        redis.linsert key, :before, pivot, member
      end

      # @see http://redis.io/commands/linsert
      #
      # @return [Fixnum] list length after operation
      #                  or -1 if pivot was not found
      #
      def insert_after(pivot, member)
        redis.linsert key, :after, pivot, member
      end

      alias :insert :insert_after

      # @see http://redis.io/commands/lrem
      #
      # @return [Fixnum] number of removed members
      #
      def delete(member, count = 0)
        redis.lrem key, count, member
      end

      # @see http://redis.io/commands/rpop
      #
      # @return [String, nil]
      #
      def pop
        desserialize redis.rpop(key)
      end

      alias :rpop :pop

      # @see http://redis.io/commands/lpop
      #
      # @return [String, nil]
      #
      def shift
        desserialize redis.lpop(key)
      end

      alias :lpop :shift

    end
  end
end
