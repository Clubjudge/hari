module Hari
  class Script

    PATH = File.expand_path('../script', __FILE__)

    attr_reader :name

    def initialize(name)
      @name, @content = name, StringIO.new
    end

    def content
      @content.string
    end

    def import(*files)
      files.each do |file|
        @content << File.read("#{PATH}/#{file}.lua")
      end

      self
    end

    def exec(*args)

    end

  end
end
