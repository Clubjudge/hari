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
        options = names.extract_options!
        i = options.fetch(:index, index)
        Array(names).map { |n| "#{n}_#{i}" }.join(', ')
      end

    end

  end
end
