module Hari
  module Keys
    class String < Key

     def string(name)
        @name = name
        self
      end

      def string!(name)
        @name = name
        to_s
      end

      def to_s
        Hari.redis.get key
      end

      def set(value)
        Hari.redis.set key, value
      end

      def length
        Hari.redis.strlen key
      end

      alias :size :length

      def range(start = nil, stop = nil)
        start ||= 0
        stop ||= -1
        Hari.redis.getrange key, start, stop
      end

      def at(index)
        Hari.redis.getrange key, index, index
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
        Hari.redis.append key, value
      end

      def +(i)
        Hari.redis.incrby key, i
        self
      end

      def -(i)
        Hari.redis.decrby key, i
        self
      end

      def bitcount(start = nil, stop = nil)
        start ||= 0
        stop ||= -1
        Hari.redis.bitcount key, start, stop
      end

      def getbit(offset)
        Hari.redis.getbit key, offset
      end

      def setbit(offset, value)
        Hari.redis.setbit key, offset, value
      end

    end
  end
end
