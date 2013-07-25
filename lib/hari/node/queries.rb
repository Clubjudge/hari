require 'hari/node/queries/list'
require 'hari/node/queries/set'
require 'hari/node/queries/sorted_set'
require 'hari/node/queries/relation'

module Hari
  class Node < Entity
    module Queries

      delegate :in, :out, to: :relation_query

      delegate :set,        :set!,        to: :set_query
      delegate :sorted_set, :sorted_set!, to: :sorted_set_query
      delegate :list,       :list!,       to: :list_query

      private

      def set_query
        Queries::Set.new self
      end

      def sorted_set_query
        Queries::SortedSet.new self
      end

      def list_query
        Queries::List.new self
      end

      def relation_query
        Queries::Relation::Start.new self
      end

    end
  end
end
