module Hari
  module Keys
    class Key

      attr_reader :node, :name

      def initialize(node = nil)
        @node = node
      end

      def key
        @key ||= begin
          prefix = node ? "#{Hari.node_key(node)}:" : ''
          prefix + name.to_s
        end
      end

    end
  end
end
