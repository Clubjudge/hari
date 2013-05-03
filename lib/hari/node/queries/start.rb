module Hari
  class Node < Entity
    module Queries
      class Start
        include Step

        attr_reader :start_node_id

        def initialize(start_node_id)
          @start_node_id = start_node_id
        end

      end
    end
  end
end
