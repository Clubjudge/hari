require 'active_support/core_ext/enumerable'

module Hari
  module Keys
    module Collection
      include ::Enumerable

      def each
        to_a.each { |e| yield e }
      end

      def count(member = nil)
        return super if member

        block_given? ? super : size
      end

      def empty?
        size == 0
      end

      def any?
        block_given? ? super : size > 0
      end

      def one?
        block_given? ? super : size == 1
      end

      def many?
        block_given? ? super : size > 1
      end

    end
  end
end
