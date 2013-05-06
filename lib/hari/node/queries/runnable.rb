module Hari
  class Node < Entity
    module Queries
      module Runnable

        # RUN BABY RUN

        def to_a
          s = script
          s.load!
          s.run script_args
        end

        alias result to_a

      end
    end
  end
end
