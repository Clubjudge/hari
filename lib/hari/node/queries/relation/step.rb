module Hari
  class Node < Entity
    module Queries
      module Relation
        module Step

          %w(in out).each do |direction|
            define_method direction do |*args|
              Relationship.new self, direction, *args
            end
          end

        end
      end
    end
  end
end
