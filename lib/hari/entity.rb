module Hari
  class Entity
    extend  ActiveModel::Naming
    extend  ActiveModel::Callbacks

    autoload :Property,      'hari/entity/property'
    autoload :Repository,    'hari/entity/repository'
    autoload :Serialization, 'hari/entity/serialization'

    include Repository
    include Serialization

    define_model_callbacks :create, :update, :destroy, :save

    property :id
    property :created_at, type: Time
    property :updated_at, type: Time

    def initialize(attrs = {})
      update_attributes attrs, save: false
    end

    def update_attributes(attrs = {}, options = {})
      return if attrs.blank?

      attrs = attrs.with_indifferent_access

      self.class.properties.each do |prop|
        write_attribute prop.name, attrs[prop.name] unless attrs[prop.name].nil?
      end

      save if options.fetch(:save, true)
    end

    def update_attribute(attribute, value)
      update_attributes attribute => value
    end

    def ==(other)
      other.is_a?(Hari::Entity) && id == other.id
    end

    def new?
      id.nil?
    end

    alias :new_record? :new?

    def persisted?
      not new?
    end

    def destroyed?
      @destroyed
    end

    def generate_id
      '_e' + ::Time.now.strftime('%Y%m%d%H%M%S') + SecureRandom.hex(3)
    end

    def to_s
      attrs = attributes
      attrs.delete 'id'

      "<#{self.class} id='#{id}' attributes=#{attrs}>"
    end

  end
end
