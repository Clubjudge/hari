require 'spec_helper'

describe Hari::Entity::Serialization::String do

  describe '.serialize, .desserialize' do
    it 'converts value to string' do
      subject.serialize(:something).should == 'something'
      subject.serialize(1).should == '1'
      subject.serialize(nil).should == nil
    end
  end

end
