module Hari
  class Node < Entity
    module Queries

      delegate :in, :out, to: :query

      private

      def query
        @query ||= Queries::Start.new(self)
      end

    end
  end
end
