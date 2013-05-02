require 'spec_helper'

describe Hari::Entity::Serialization::Integer do

  describe '.serialize, .desserialize' do
    it 'converts to integer' do
      subject.serialize('1200').should == 1200
      subject.serialize(1200).should == 1200
    end

    context 'when an invalid value is serialized' do
      it 'raises an error' do
        expect { subject.desserialize('not an integer') }.to raise_error
      end
    end
  end

end
