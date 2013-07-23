require 'spec_helper'

describe Hari::Node::Queries::Set do

  before { Hari.redis.flushdb }

  let(:node)    { Hari.node user: 10 }
  let(:friends) { node.set :friends }

  it 'does set operations' do
    friends.add 20, 30, 40, 50, 60, 70

    friends.include?(20).should be_true
    friends.members.sort.should eq %w(20 30 40 50 60 70)
    friends.count.should eq(6)

    friends.delete 30, 40
    friends.count.should eq(4)

    friends << 80
    friends.count.should eq(5)

    members = %w(20 50 60 70 80)
    node.set!(:friends).sort.should eq(members)

    random_members = friends.rand(2)
    random_members.each { |r| members.include?(r).should be_true }
    friends.count.should eq(5)

    other_node_friends = Hari.node(user: 20).set(:friends)
    other_node_friends.add 30, 15, 70, 50

    (friends & other_node_friends).sort.should eq %w(50 70)

    (friends - other_node_friends).sort.should eq %w(20 60 80)

    popped_member = friends.pop
    members.include?(popped_member).should be_true
    members.delete popped_member
    friends.count.should eq(4)
  end

end
