module Hari
  class Entity
    class Property
      module Builder

        def property(name, options = {})
          attr_reader name
          define_attribute_method name

          validates_presence_of name if options[:required]

          define_method "#{name}=" do |value|
            unless send(name) == value
              send "#{name}_will_change!"
            end

            instance_variable_set "@#{name}", value
          end

          if options[:type] == Serialization::Boolean
            define_method("#{name}?") { send name }
          end

          properties << Property.new(self, name, options)
        end

        def properties(*args)
          options = args.extract_options!
          args.each { |name| property name, options }

          @properties ||= begin
            if self == Hari::Entity
              []
            else
              entities_ancestors = ancestors.select do |a|
                a.ancestors.include? Hari::Entity
              end

              entity = entities_ancestors[1]
              entity ? entity.properties.dup : []
            end
          end
        end

      end
    end
  end
end
