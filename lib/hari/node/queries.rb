module Hari
  class Node < Entity
    module Queries
      autoload :Relation, 'hari/node/queries/relation'
      autoload :Type,     'hari/node/queries/type'

      delegate :in, :out, to: :relation_query

      delegate :hash,       :hash!,       to: :hash_query
      delegate :list,       :list!,       to: :list_query
      delegate :set,        :set!,        to: :set_query
      delegate :sorted_set, :sorted_set!, to: :sorted_set_query
      delegate :string,     :string!,     to: :string_query

      private

      def hash_query
        Keys::Hash.new query_node
      end

      def list_query
        Keys::List.new query_node
      end

      def set_query
        Keys::Set.new query_node
      end

      def sorted_set_query
        Keys::SortedSet.new query_node
      end

      def string_query
        Keys::String.new query_node
      end

      def relation_query
        Queries::Relation::Start.new query_node
      end

      def query_node
        self.kind_of?(Hari::Node) ? self : nil
      end

    end
  end
end
