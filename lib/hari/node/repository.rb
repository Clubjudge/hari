module Hari
  class Node < Entity
    module Repository
      extend ActiveSupport::Concern

      module ClassMethods

        def find_one(id, options = {})
          id = "#{node_type}##{id}" unless id.to_s.include?('#')
          super id, options
        end

        def find_many(ids, options = {})
          ids = ids.map do |id|
            id.to_s.include?('#') ? id : "#{node_type}##{id}"
          end

          super ids, options
        end

      end
    end
  end
end
