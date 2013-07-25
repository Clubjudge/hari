module Hari
  class Node < Entity
    module Queries
      class Relation
        module Step

          %w(in out).each do |direction|
            define_method direction do |*args|
              Relation.new self, direction, *args
            end
          end

        end
      end
    end
  end
end
