$:.push '../lib'

require 'hari'
require 'pry'

class TestModel < Hari::Entity
  property :name
  property :birth,  type: Date
  property :points, type: Integer
end
