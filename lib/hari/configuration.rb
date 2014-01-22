require 'hari/configuration/redis'

module Hari
  #
  # Contains custom configuration modules for Hari
  #
  module Configuration
    include Redis

    # Configure Hari through this method
    #
    # @example Hari.configure { |c| c.redis = r }
    # @return [void]
    #
    def configure
      yield self if block_given?
    end

  end
end
