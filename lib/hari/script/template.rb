module Hari
  class Script
    class Template < OpenStruct

      def get_bindings
        binding()
      end

      def _id
        @_id ||= SecureRandom.hex(3)
      end

      def locals_from_args(names)
        names.each_with_index.map do |name, i|
          "local #{name}_#{_id} = ARGV[#{args_index + i + 1}]"
        end.join("\n")
      end

      def l(*names)
        names.map { |n| "#{n}_#{_id}" }.join(', ')
      end

    end

  end
end
