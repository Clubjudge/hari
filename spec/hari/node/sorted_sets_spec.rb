require 'spec_helper'

describe Hari::Node::Queries::SortedSet do

  let(:node) { Hari.node user: 10 }
  subject    { node.sorted_set :friends }

  before { subject.add 10, 'john', 30, 'bill', 50, 'jack' }

  specify '#name' do
    subject.name.should eq(:friends)
  end

  specify '#range + #range_with_scores + #members + #sorted_set!' do
    node.sorted_set!(:friends).should eq %w(john bill jack)
    subject.members.should eq %w(john bill jack)
    subject.range.should eq %w(john bill jack)

    subject.range(0, 1).should eq %w(john bill)

    subject.range_with_scores.should eq [['john', 10.0], ['bill', 30.0], ['jack', 50.0]]
    subject.range(0, 1, with_scores: true).should eq [['john', 10.0], ['bill', 30.0]]

    subject.revrange(0, 1).should eq %w(jack bill)
    subject.revrange.should eq %w(jack bill john)
    subject.reverse_range.should eq %w(jack bill john)
    subject.desc_range.should eq %w(jack bill john)

    subject.revrange_with_scores.should eq [['jack', 50.0], ['bill', 30.0], ['john', 10.0]]
  end

  specify '#include? + #member?' do
    subject.include?('jack').should be_true
    subject.member?('bill').should be_true
    subject.include?('steve').should be_false
  end

  specify '#count + #size + #length' do
    subject.count.should eq(3)
    subject.size.should eq(3)
    subject.length.should eq(3)
  end

  specify '#one? + #many?' do
    subject.should_not be_one
    subject.should be_many

    zset = node.sorted_set(:enemies)
    zset.add 70, 'jill'
    zset.should be_one
    zset.should_not be_many
  end

  specify '#empty?' do
    subject.should_not be_empty
    node.sorted_set(:wtfs).should be_empty
  end

  specify '#delete' do
    subject.delete 'jack', 'bill', 'jill'
    subject.members.should eq %w(john)
  end

  specify '#score' do
    subject.score('john').should eq(10.0)
    subject.score('steve').should_not be
  end

  specify '#rank + #revrank' do
    subject.rank('john').should eq(0)
    subject.ranking('bill').should eq(1)
    subject.position('jack').should eq(2)

    subject.revrank('john').should eq(2)
    subject.reverse_ranking('bill').should eq(1)
    subject.reverse_position('jack').should eq(0)
  end

  specify '#trim_by_rank' do
    subject.trim_by_rank 1, 1
    subject.members.should eq %w(john jack)
  end

  specify '#trim_by_score' do
    subject.trim_by_score 5, 15
    subject.members.should eq %w(bill jack)
  end

end
