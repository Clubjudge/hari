module Hari::Node::Queries::Relation
  module Backend
    module List
      extend self

      def fetch(node, options = {})
        list = node.list list_name(options)
        send "fetch_#{options[:result]}", list, options
      end

      def fetch_relations_ids(list, options = {})
        start = options.fetch(:from, 0)
        stop  = options.limit(:limit, -1)

        list.range start, stop
      end

      def fetch_nodes_ids(list, options)
        index = list.name =~ /in$/ ? 1 : 2
        fetch_relations_ids(list, options).map { |r| r.split(':')[index] }
      end

      def fetch_count(list, options)
        list.count
      end

      private

      def list_name(options)
        "#{options[:relation]}:#{options[:direction]}"
      end

    end
  end
end
