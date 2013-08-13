require 'spec_helper'

describe Hari::Keys::Hash do

  let(:node) { Hari.node user: 10 }
  subject    { node.hash :preferences }

  before do
    subject[:genre] = 'afrobeat'
  end

  specify '#hash' do
    node.hash.should be_a(Fixnum)
    node.hash(:preferences).should be_a(Hari::Keys::Hash)
  end

  specify '#hash! + #to_a' do
    node.hash!(:preferences).should eq('genre' => 'afrobeat')
    subject.to_h.should eq('genre' => 'afrobeat')
  end

  specify '#delete' do
    subject.delete :genre
    subject.to_h.should eq({})
  end

  specify '#key? + #[]' do
    subject.key?(:genre).should be_true
    subject.key?(:city).should be_false
    subject.has_key?(:genre).should be_true
    subject.member?(:genre).should be_true

    subject[:genre].should eq('afrobeat')
  end

  specify '#keys + #values + #values_at' do
    subject[:city] = 'Amsterdam'
    subject.keys.sort.should eq %w(city genre)
    subject.values.sort.should eq %w(Amsterdam afrobeat)
    subject[:country] = 'Netherlands'

    subject.values_at(:city, :country).should eq %w(Amsterdam Netherlands)
  end

  specify '#count' do
    subject.count.should eq(1)
    subject[:one] = 'more'

    subject.count.should eq(2)
    subject.size.should eq(2)
    subject.length.should eq(2)
  end

end
