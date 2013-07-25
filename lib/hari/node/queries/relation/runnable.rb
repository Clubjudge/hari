module Hari
  class Node < Entity
    module Queries
      class Relation
        module Runnable

          def result
            result = call(true)

            case result_type(true)
            when :nodes
              result.map &Hari::Node.method(:from_source)
            else
              result
            end
          end

          alias :to_a :result

        end
      end
    end
  end
end
