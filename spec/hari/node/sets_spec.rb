require 'spec_helper'

describe Hari::Node::Queries::Set do

  let(:node) { Hari.node user: 10 }
  subject    { node.set :friends }

  before { subject.add 10, 20, 30 }

  specify '#name' do
    subject.name.should eq(:friends)
  end

  specify '#members + #set!' do
    node.set!(:friends).should eq %w(10 20 30)
    subject.members.should eq %w(10 20 30)
  end

  specify '#include? + #member?' do
    subject.include?(20).should be_true
    subject.member?(20).should be_true
    subject.include?(40).should be_false
  end

  specify '#count + #size + #length' do
    subject.count.should eq(3)
    subject.size.should eq(3)
    subject.length.should eq(3)
  end

  specify '#one? + #many?' do
    subject.should_not be_one
    subject.should be_many

    set = node.set(:enemies)
    set.add 90
    set.should be_one
    set.should_not be_many
  end

  specify '#empty?' do
    subject.should_not be_empty
    node.set(:wtfs).should be_empty
  end

  specify '#delete' do
    subject.delete 30, 40
    subject.members.should eq %w(10 20)
  end

  specify '#<<' do
    subject << 40
    subject.include?(40).should be_true
  end

  specify '#rand' do
    %w(10 20 30).include?(subject.rand.first).should be_true
    subject.rand(3).sort.should eq %w(10 20 30)
    subject.count.should eq(3)
  end

  specify '#intersect + #&' do
    other_friends = Hari.node(user: 20).set(:friends)
    other_friends.add 20, 30, 40, 50

    (subject & other_friends).sort.should eq %w(20 30)
    subject.intersect(other_friends).sort.should eq %w(20 30)
  end

  specify '#diff + #-' do
    other_friends = Hari.node(user: 20).set(:friends)
    other_friends.add 20, 30, 40, 50

    (subject - other_friends).sort.should eq %w(10)
    subject.diff(other_friends).sort.should eq %w(10)
  end

  specify '#pop' do
    member = subject.pop
    %w(10 20 30).include?(member).should be_true
    subject.count.should eq(2)
    subject.members.include?(member).should be_false
  end

end
