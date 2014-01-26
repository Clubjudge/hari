module Hari
  module Keys
    class String < Key

      def string(name)
        @name = name
        self
      end

      def string!(name)
        string(name).to_s
      end

      def to_s
        redis.get key
      end

      def set(value)
        redis.set key, value
      end

      def length
        redis.strlen key
      end

      alias :size :length

      def range(start = nil, stop = nil)
        redis.getrange key, start || 0, stop || -1
      end

      def at(index)
        redis.getrange key, index, index
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

      def <<(value)
        redis.append key, value
      end

      def +(i)
        redis.incrby key, i
        self
      end

      def -(i)
        redis.decrby key, i
        self
      end

      def bitcount(start = nil, stop = nil)
        redis.bitcount key, start || 0, stop || -1
      end

      def getbit(offset)
        redis.getbit key, offset
      end

      def setbit(offset, value)
        redis.setbit key, offset, value
      end

    end
  end
end
