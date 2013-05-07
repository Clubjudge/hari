require 'spec_helper'

describe Hari::Node do
  it 'can has queries' do
    Hari.redis.flushdb

    john = TestNode.create(name: 'John', model_id: 25)
    mary = TestNode.create(name: 'Mary', model_id: 35)
    bill = TestNode.create(name: 'Bill', model_id: 40)
    Hari::Relationship.create :follow, john, mary
    Hari::Relationship.create :follow, john, bill

    john.out(:follow).to_a.should eq [bill, mary]
    john.out(:follow).limit(1).to_a.should eq [bill]
    john.out(:follow).limit(1).skip(1).to_a.should eq [mary]
  end
end
