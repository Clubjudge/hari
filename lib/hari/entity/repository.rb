module Hari
  class Entity
    #
    # This module is responsible for persistency of Entities in Redis.
    #
    module Repository
      extend ActiveSupport::Concern

      # Creates or updates the instance, also
      # running before_save and after_save callbacks,
      # if there are any of them.
      #
      # @return [Hari::Entity] the saved entity
      #
      def create_or_update
        run_callbacks(:save) { new? ? create : update }.tap do
          @changed_attributes.clear
        end
      end

      alias :save :create_or_update

      # Creates entity in Redis
      #
      # @raise [Hari::ValidationsFailed] if entity is not valid
      #
      # @return [self]
      #
      def create
        run_callbacks :create do
          fail Hari::ValidationsFailed, self unless valid?

          @id ||= generate_id
          @created_at ||= Time.now
          self.updated_at = Time.now
          persist
        end

        self
      end

      # Updates entity in Redis
      #
      # @raise [Hari::ValidationsFailed] if entity is not valid
      #
      # @return [self]
      #
      def update
        run_callbacks :update do
          fail Hari::ValidationsFailed, self unless valid?

          self.updated_at = Time.now.utc.iso8601
          persist
        end
      end

      # Persists entity in Redis
      #
      # @return [self]
      #
      def persist
        source = to_json
        @previously_changed = changes
        Hari.redis.set id, source

        self
      end

      # Deletes an instance, also running
      # before_destroy and after_destroy callbacks,
      # if there are any of them.
      #
      # @return [self]
      #
      def delete
        run_callbacks :destroy do
          Hari.redis.del id
          @destroyed = true
        end

        self
      end

      alias :destroy :delete

      module ClassMethods

        # Creates a new entity
        #
        # @param attrs [Hash] new entity attributes
        #
        # @return [Hari::Entity]
        #
        def create(attrs = {})
          new(attrs).save
        end

        # Finds one or more entities by their ids
        #
        # @overload find(*ids, options = {})
        #
        # @param ids [Array<#to_s>] one or more ids
        #
        # @param options [Hash] currently no option accepted
        #
        # @return [Hari::Entity, Array<Hari::Entity>, nil]
        #
        def find(*args)
          options = args.extract_options!
          args.flatten!
          return if args.empty?

          args = args.map { |a| a.to_s.gsub /^hari\:/, '' }
          args.one? ? find_one(args[0], options) : find_many(args, options)
        end

        # Finds an entity by its id
        #
        # @param id [String]
        #
        # @param options [Hash] currently no option accepted
        #
        # @return [Hari::Entity, nil]
        #
        def find_one(id, options = {})
          from_json Hari.redis.get(id)
        end

        # Finds entities by their ids
        #
        # @param ids [Array<String>]
        #
        # @param options [Hash] currently no option accepted
        #
        # @return [Array<Hari::Entity>, []]
        #
        def find_many(ids, options = {})
          return [] if ids.empty?

          Hari.redis.mget(ids).map &method(:from_json)
        end

      end

    end
  end
end
