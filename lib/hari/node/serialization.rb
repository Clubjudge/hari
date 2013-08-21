module Hari
  class Node < Entity
    module Serialization

      def from_source(source)
        return if source.blank?

        case source
        when ::String
          hash = Yajl::Parser.parse(source)
          source_class(hash).from_hash hash
        when ::Hash
          source_class(source).from_hash source
        end
      end

      private

      def source_class(source)
        source['id'].split('#').first.camelize.constantize
      end

    end
  end
end
