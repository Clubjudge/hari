require 'spec_helper'

describe Hari::Keys::List do

  let(:node) { Hari.node user: 10 }
  subject    { node.list :friends }

  before { subject.add 10, 20, 30, 40, 50, 60 }

  specify '#name' do
    subject.name.should eq(:friends)
  end

  specify '#range + #members + #list! + ' +
          '#[i] + #[i, j], + #[i..j] + ' +
          '#at + #index + #from + #to' do
    node.list!(:friends).should eq %w(10 20 30 40 50 60)
    subject.members.should eq %w(10 20 30 40 50 60)
    subject.range.should eq %w(10 20 30 40 50 60)

    subject.range(1, 3).should eq %w(20 30 40)
    subject[1, 3].should eq %w(20 30 40)
    subject[1..3].should eq %w(20 30 40)
    subject[1].should eq('20')

    subject.at(1).should eq('20')
    subject.index(1).should eq('20')
    subject.from(2).should eq %w(30 40 50 60)
    subject.to(3).should eq %w(10 20 30 40)
  end

  specify '#include? + #member?' do
    subject.include?('20').should be_true
    subject.member?('20').should be_true
    subject.include?('70').should be_false
  end

  specify '#count + #size + #length' do
    subject.count.should eq(6)
    subject.size.should eq(6)
    subject.length.should eq(6)
  end

  specify '#one? + #many?' do
    subject.should_not be_one
    subject.should be_many

    list = node.list(:enemies)
    list.add 90
    list.should be_one
    list.should_not be_many
  end

  specify '#empty?' do
    subject.should_not be_empty
    node.list(:wtfs).should be_empty
  end

  specify '#delete' do
    subject.delete 30
    subject.members.should eq %w(10 20 40 50 60)
  end

  specify '#<<' do
    subject << 90
    subject.include?('90').should be_true
    subject.pop.should eq('90')
  end

  specify '#pop + #rpop + #shift + #lpop' do
    subject.pop.should eq('60')
    subject.count.should eq(5)
    subject.include?('60').should be_false

    subject.rpop.should eq('50')
    subject.count.should eq(4)
    subject.include?('50').should be_false

    subject.lpop.should eq('10')
    subject.count.should eq(3)
    subject.include?('10').should be_false

    subject.shift.should eq('20')
    subject.count.should eq(2)
    subject.include?('20').should be_false
  end

  specify '#<< + #push + #rpush + #add + #lpush + #first + #last' do
    subject << 80
    subject.last.should eq('80')

    subject.push 90
    subject.last.should eq('90')

    subject.rpush 100
    subject.last.should eq('100')

    subject.add 200
    subject.last.should eq('200')

    subject.lpush 300
    subject.first.should eq('300')
  end

  specify '#[]=' do
    subject[1] = 77
    subject.members.should eq %w(10 77 30 40 50 60)
  end

  specify '#trim' do
    subject.trim 2, 4
    subject.members.should eq %w(30 40 50)
  end

  specify '#insert + #insert_before + #insert_after' do
    subject.insert '20', '55'
    subject.members.should eq %w(10 20 55 30 40 50 60)

    subject.insert_after '40', '66'
    subject.members.should eq %w(10 20 55 30 40 66 50 60)

    subject.insert_before '66', '99'
    subject.members.should eq %w(10 20 55 30 40 99 66 50 60)
  end

end
