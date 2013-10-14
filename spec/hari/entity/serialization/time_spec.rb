require 'spec_helper'

describe Hari::Entity::Serialization::Time do

  describe '.serialize, .desserialize' do
    it 'converts value to string' do
      time = Time.new(2012, 04, 30, 12, 05, 50, '+00:00')
      subject.serialize(time).should == '20120430120550.000000'
      subject.serialize('2012-04-30T12:05:50').should == '20120430120550.000000'
      subject.desserialize('20120430120550').should == time.utc
    end
  end

end
