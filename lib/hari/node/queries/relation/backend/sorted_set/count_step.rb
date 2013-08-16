module Hari::Node::Queries
  class Relation
    module Backend
      module SortedSet
        module CountStep

          def step_count(start_node, nodes_ids, options)
            # CONSIDER LIMIT AND FROM
            nodes_ids.inject(0) { |b, n| b + Hari(n).sorted_set(set_name(options)).count }
          end

        end
      end
    end
  end
end
