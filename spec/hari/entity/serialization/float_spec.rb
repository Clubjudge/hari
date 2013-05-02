require 'spec_helper'

describe Hari::Entity::Serialization::Float do

  describe '.serialize, .desserialize' do
    it 'converts to float' do
      subject.serialize(4237.55).should == 4237.55
      subject.serialize('4237.55').should == 4237.55
      subject.serialize('4237').should == 4237.0
    end

    context 'when an invalid value is desserialized' do
      it 'raises an error' do
        expect { subject.desserialize('not a float') }.to raise_error
      end
    end
  end

end
