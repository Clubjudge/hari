module Hari
  class Node < Entity
    module Serialization

      def from_source(source)
        return if source.blank?

        hash = Yajl::Parser.parse(source)
        klass = hash['id'].split('#').first.camelize.constantize

        attrs = hash.inject({}) do |buffer, (key, value)|
          if prop = klass.properties.find { |p| p.name == key }
            buffer[key] = prop.desserialize(value)
          end

          buffer
        end

        klass.new attrs
      end

    end
  end
end
