require 'spec_helper'

describe Hari::Keys::String do

  let(:node) { Hari.node user: 10 }
  subject    { node.string :bio }

  specify '#string! + #to_s + #set' do
    subject.set 'lol'
    node.string!(:bio).should eq('lol')

    subject.to_s.should eq('lol')
  end

  specify '#length' do
    subject.set 'lol'
    subject.length.should eq(3)
    subject.size.should eq(3)
  end

  specify '#at + #range + #[]' do
    subject.set 'de his omnibus non cogitavi'

    subject.at(7).should eq('o')
    subject[7].should eq('o')

    subject.range(7, 13).should eq('omnibus')
    subject[7, 13].should eq('omnibus')
    subject[7..13].should eq('omnibus')
  end

  specify '#<<' do
    subject.set 'lol'
    subject << 'omg'
    subject << 'bbq'

    subject.to_s.should eq('lolomgbbq')
  end

  specify '#+ + #-' do
    subject.set 1
    subject + 4
    subject.to_s.should eq('5')

    subject - 7
    subject.to_s.should eq('-2')
  end

  specify '#bitcount + #getbit + #setbit' do
    subject.set 'lol'
    subject.bitcount.should eq(14)
    subject.getbit(3).should eq(0)
    subject.setbit(4, 1)
    subject.getbit(4).should eq(1)
  end

end
