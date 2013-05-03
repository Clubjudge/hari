module Hari
  class Node < Entity
    module Queries

      def query
        @query || Queries::Start.new(self)
      end

      delegate :in, :out, to: :query

    end
  end
end
