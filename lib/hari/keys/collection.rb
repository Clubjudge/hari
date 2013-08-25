module Hari
  module Keys
    module Collection
      include ::Enumerable

      def each
        to_a.each { |e| yield e }
      end
    end
  end
end
