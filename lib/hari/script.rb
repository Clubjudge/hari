module Hari
  class Script

    PATH = File.expand_path('../script', __FILE__)

    attr_reader :name, :content, :args_count, :imported, :sha

    def initialize(name = SecureRandom.hex(6), content = '')
      @name, @content = name, content
      @args_count = 0
      @imported = []
    end

    def increment_args(count)
      @args_count += count
      self
    end

    def import(*files)
      options = files.extract_options!

      files.each do |file|
        next if imported.include?(file) && !options[:hard]
        @content << resolve_template(file, options)
        imported << file
      end

      @sha = nil # after change, reset script load

      self
    end

    def import!(*files)
      import *files, hard: true
    end

    def load!
      @sha ||= Hari.redis.script(:load, content)
    end

    def run(args)
      Hari.redis.evalsha @sha, [], args
    end

    private

    def resolve_template(file, options)
      template = ERB.new(File.read("#{PATH}/#{file}.lua.erb"))
      args = options.merge(args_index: args_count, index: SecureRandom.hex(6))
      template.result OpenStruct.new(args).instance_eval('binding()')
    end

  end
end
