module Hari
  class Node < Entity
    module Repository
      extend ActiveSupport::Concern

      def reindex(options = {})
        self.class.indexed_properties.each do |property|
          if change = previous_changes[property.name]
            previous, current = change

            Index.new(property, previous).delete self
            Index.new(property, current).add self
          elsif options[:force_index]
            value = send(property.name)
            Index.new(property, value).add self
          end
        end
      end

      def remove_from_indexes
        self.class.indexed_properties.each do |property|
          value = send(property.name)
          Index.new(property, value).delete self
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

        def find_by(name, value)
          if property = indexed_properties.find { |p| p.name.to_s == name.to_s }
            Index.new property, value
          else
            fail "missing index for key #{name}"
          end
        end

        def where(conditions = {})
          conditions.inject(nil) do |index, (key, value)|
            query = find_by(key, value)
            index ? index.append(query) : query
          end
        end

      end
    end
  end
end
