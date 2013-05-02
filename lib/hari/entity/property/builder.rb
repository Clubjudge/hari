module Hari
  class Entity
    class Property
      module Builder

        def property(name, options = {})
          attr_accessor name
          validates_presence_of name if options[:required]

          self.properties << Property.new(name, options)
        end

        def properties(*args)
          options = args.extract_options!
          args.each { |name| property name, options }

          @properties ||= begin
            self == Hari::Entity ? [] : Hari::Entity.properties.dup
          end
        end

      end
    end
  end
end
