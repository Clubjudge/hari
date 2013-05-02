module Hari
  class HariException      < RuntimeError;  end
  class NotFound           < HariException; end
  class InvalidQuery       < HariException; end
  class SerializationError < HariException; end

  class ValidationsFailed < HariException
    attr_reader :object

    def initialize(object)
      @object = object
      errors  = @object.errors.full_messages.to_sentence
      super errors
    end
  end

end
