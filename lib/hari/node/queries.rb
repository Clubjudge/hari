module Hari
  class Node < Entity
    module Queries

      delegate :set, :set!, to: :set_query
      delegate :in, :out,   to: :relation_query

      private

      def query
        @query
      end

      def set_query
        @query ||= Queries::Set.new(self)
      end

      def relation_query
        @query ||= Queries::Relation::Start.new(self)
      end

    end
  end
end
