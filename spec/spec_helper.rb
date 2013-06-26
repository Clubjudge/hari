$:.push '../lib'

require 'hari'
require 'pry'
require 'delorean'
require 'active_support/core_ext/numeric/time'

class TestEntity < Hari::Entity
  property :name
  property :birth,  type: Date
  property :points, type: Integer
end

class TestNode < Hari::Node
  property :name
end
