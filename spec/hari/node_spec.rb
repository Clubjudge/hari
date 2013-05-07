require 'spec_helper'

describe Hari::Node do
  it 'can has queries' do
    Hari.redis.flushdb

    john = TestNode.create(name: 'John', model_id: 25)
    mary = TestNode.create(name: 'Mary', model_id: 35)
    Hari::Relationship.create :follow, john, mary

    john.out(:follow).to_a.should eq [mary]
  end
end
