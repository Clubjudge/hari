$:.push '../lib'

require 'hari'
require 'pry'
require 'delorean'
require 'active_support/core_ext/numeric/time'

class TestEntity < Hari::Entity
  property :name
  property :country,     default: 'US'
  property :birth,       type: Date
  property :points,      type: Integer
  property :preferences, type: Hash
  property :friends_ids, type: Array
  property :male,        type: Boolean, default: true
end

class TestNode < Hari::Node
  property :name
end

RSpec.configure do |config|
  config.before(:each) { Hari.redis.flushdb }
end
