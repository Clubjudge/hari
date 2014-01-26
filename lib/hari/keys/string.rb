module Hari
  module Keys
    #
    # Enables Redis Strings in Hari.
    #
    # Strings are the most basic kind of Redis value.
    #
    # Redis Strings are binary safe, this means that
    # a Redis string can contain any kind of data,
    # for instance a JPEG image or a serialized Ruby object.
    #
    class String < Key

      # Sets the string name
      #
      # @return [self]
      #
      def string(name)
        @name = name
        self
      end

      # Sets the string name and
      # fetches its value
      #
      # @return [String]
      #
      def string!(name)
        string(name).to_s
      end

      # @see http://redis.io/commands/get
      #
      # @return [String]
      #
      def to_s
        redis.get key
      end

      # @see http://redis.io/commands/set
      #
      # @return ['OK']
      #
      def set(value)
        redis.set key, value
      end

      # @see http://redis.io/commands/strlen
      #
      # @return [Fixnum] the string length
      #
      def length
        redis.strlen key
      end

      alias :size :length

      # @see http://redis.io/commands/getrange
      #
      # @return [String, nil]
      #
      def range(start = nil, stop = nil)
        redis.getrange key, start || 0, stop || -1
      end

      # @see http://redis.io/commands/getrange
      #
      # @return [String, nil]
      #
      def at(index)
        redis.getrange key, index, index
      end

      # @see http://redis.io/commands/getrange
      #
      # @return [String, nil]
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

      # @see http://redis.io/commands/append
      #
      # @return [Fixnum] length of string after append
      #
      def <<(value)
        redis.append key, value
      end

      # @see http://redis.io/commands/incrby
      #
      # @return [self]
      #
      def +(i)
        redis.incrby key, i
        self
      end

      # @see http://redis.io/commands/decrby
      #
      # @return [self]
      #
      def -(i)
        redis.decrby key, i
        self
      end

      # @see http://redis.io/commands/bitcount
      #
      # @return [Fixnum] number of bits set to 1
      #
      def bitcount(start = nil, stop = nil)
        redis.bitcount key, start || 0, stop || -1
      end

      # @see http://redis.io/commands/getbit
      #
      # @return [0, 1]
      #
      def getbit(offset)
        redis.getbit key, offset
      end

      # @see http://redis.io/commands/setbit
      #
      # @return [0, 1]
      #
      def setbit(offset, value)
        redis.setbit key, offset, value
      end

    end
  end
end
