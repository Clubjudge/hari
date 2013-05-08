module Hari
  class Node < Entity
    module Queries
      module Runnable

        def to_a
          script.load!
          args = script_args(true)
          handle_result script.run(args)
        end

        alias result to_a

        private

        def handle_result(result)
          case result_type(true)
          when :nodes
            result.map &Hari::Node.method(:from_source)
          else
            result
          end
        end


      end
    end
  end
end
