$:.push '../lib'

require 'hari'
require 'pry'

class TestEntity < Hari::Entity
  property :name
  property :birth,  type: Date
  property :points, type: Integer
end

class TestNode < Hari::Node
  property :name
end
