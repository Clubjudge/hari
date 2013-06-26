module Hari
  class Entity
    module Repository
      extend ActiveSupport::Concern

      def create_or_update
        run_callbacks(:save) { new? ? create : update }
      end

      alias save create_or_update

      def create
        run_callbacks :create do
          fail Hari::ValidationsFailed, self unless valid?

          @id ||= generate_id
          self.created_at = Time.now
          self.updated_at = Time.now
          persist
        end

        self
      end

      def update
        run_callbacks :update do
          fail Hari::ValidationsFailed, self unless valid?

          self.updated_at = Time.now.utc.iso8601
          persist
        end

        self
      end

      def persist
        Hari.redis.set id, to_json
      end

      def delete
        run_callbacks :destroy do
          Hari.redis.del id
          @destroyed = true
        end

        self
      end

      alias destroy delete

      module ClassMethods

        def create(attrs = {})
          new(attrs).save
        end

        def find(*args)
          options = args.extract_options!
          args.flatten!
          args = args.map { |a| a.gsub(/^hari\:/, '') }
          args.one? ? find_one(args[0], options) : find_many(args, options)
        end

        def find_one(id, options = {})
          from_json Hari.redis.get(id)
        end

        def find_many(ids, options = {})
          Hari.redis.mget(ids).map &method(:from_json)
        end

      end

    end
  end
end
