require 'active_support/core_ext/enumerable'

module Hari
  module Keys
    #
    # Implements collection methods for keys that are collections
    #
    module Collection
      include ::Enumerable

      # Yields block for each element in the collection
      #
      # @return [Enumerator]
      #
      def each
        to_a.each { |e| yield e }
      end

      # @return [true] if collection has no elements
      # @return [false] if collection has elements
      #
      def empty?
        size == 0
      end

      # If a member is passed, returns the repetitions of it.
      #
      # It's also possible to count members that evaluates true
      # for the block given.
      #
      # Otherwise, it just count the number of elements
      # in the collection.
      #
      # @param member [Object] counts repetitions of member
      #
      # @return [Fixnum] collection size
      #
      def count(member = nil)
        return super if member

        block_given? ? super : size
      end

      # When called with no block, returns if size > 0.
      #
      # Otherwise, return if there is any element that
      # evaluates true for the block given.
      #
      # @return [true, false]
      #
      def any?
        block_given? ? super : size > 0
      end

      # When called with no block, returns if size == 1.
      #
      # Otherwise, return if there is one and only one
      # element that evaluates true for the block given.
      #
      # @return [true, false]
      #
      def one?
        block_given? ? super : size == 1
      end

      # When called with no block, returns if size > 1.
      #
      # Otherwise, return if there is more than one
      # element that evaluates true for the block given.
      #
      # @return [true, false]
      #
      def many?
        block_given? ? super : size > 1
      end

    end
  end
end
