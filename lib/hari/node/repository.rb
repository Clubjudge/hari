module Hari
  class Node < Entity
    module Repository
      extend ActiveSupport::Concern

      def reindex
        self.class.indexed_properties.each do |property|
          next unless change = previous_changes[property.name]

          previous, current = change

          Index.new(property, previous).delete(self) if previous
          Index.new(property, current).add(self)     if current
        end
      end

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

        def find_by_index(name, value, page = nil, per_page = nil)
          if property = indexed_properties.find { |p| p.name.to_s == name.to_s }
            Index.new(property, value).list(page, per_page)
          end
        end

      end
    end
  end
end
