module Hari
  class Node < Entity
    module Repository
      extend ActiveSupport::Concern

      # Reindexes a node that has changed
      #
      # @param options [Hash] force_index: true reindexes
      #                       even if there are no changes
      #
      # @return [void]
      #
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

      # Removes a node from all indexes
      #
      # @return [void]
      #
      def remove_from_indexes
        self.class.indexed_properties.each do |property|
          value = send(property.name)
          Index.new(property, value).delete self
        end
      end

      module ClassMethods

        # Finds a node by its id.
        #
        # Changes original method from [Hari::Entity::Repository]
        # to accept node id notation
        #
        # @return [Hari::Node, nil]
        #
        def find_one(id, options = {})
          id = "#{node_type}##{id}" unless id.to_s.include?('#')
          super id, options
        end

        # Finds nodes by their ids
        #
        # Changes original method from [Hari::Entity::Repository]
        # to accept node id notation
        #
        # @return [Array<Hari::Node>]
        #
        def find_many(ids, options = {})
          ids = ids.map do |id|
            id.to_s.include?('#') ? id : "#{node_type}##{id}"
          end

          super ids, options
        end

        # Lazy search for nodes by an indexed property
        #
        # @param name [#to_s] Indexed property name
        # @param value [Object] Indexed property value
        #
        # @return [Index]
        #
        def find_by(name, value)
          if property = indexed_properties.find { |p| p.name.to_s == name.to_s }
            Index.new property, value
          else
            fail "missing index for key #{name}"
          end
        end

        # Lazy search for nodes for indexed properties
        #
        # @param conditions [Hash] indexed properties names and values
        #
        # @return [Index] index query
        #
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
