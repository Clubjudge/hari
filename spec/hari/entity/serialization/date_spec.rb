require 'spec_helper'

describe Hari::Entity::Serialization::Date do

  describe '.serialize' do
    it 'converts to date string' do
      subject.serialize(Date.new(2011, 07, 01)).should == '2011-07-01'
    end
  end

  describe '.desserialize' do
    it 'converts to date' do
      subject.desserialize('2011-07-01').should == Date.new(2011, 07, 01)
    end

    context 'when an invalid value is desserialized' do
      it 'raises an error' do
        expect { subject.desserialize('not a date') }.to raise_error
      end
    end
  end

end
