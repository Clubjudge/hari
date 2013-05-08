module Hari
  class Node < Entity
    module Queries
      class Start
        include Step

        attr_reader :start_node, :level

        def initialize(start_node)
          @start_node = start_node
          @level = 0
        end

        def script(result, s)
          s.import(:base, :start_node).increment_args 1
        end

        def script_args
          [start_node.generate_id]
        end

      end
    end
  end
end
