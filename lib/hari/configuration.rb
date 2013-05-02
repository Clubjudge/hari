require 'hari/configuration/redis'

module Hari
  module Configuration
    include Redis

    def configure
      yield self if block_given?
    end

  end
end
