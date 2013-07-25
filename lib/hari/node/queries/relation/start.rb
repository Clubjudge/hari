module Hari
  class Node < Entity
    module Queries
      class Relation
        class Start
          include Relation::Step

          attr_reader :node, :level

          def initialize(node)
            @node = node
            @level = 0
          end

        end
      end
    end
  end
end
