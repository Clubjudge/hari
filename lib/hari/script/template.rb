module Hari
  class Script
    class Template < OpenStruct

      def get_bindings
        binding()
      end

      def locals_from_args(names)
        names.each_with_index.map do |name, i|
          "local #{name}_#{index} = ARGV[#{args_index + i + 1}]"
        end.join("\n")
      end

      def l(*names)
        names.map { |n| "#{n}_#{index}" }.join(', ')
      end

    end

  end
end
