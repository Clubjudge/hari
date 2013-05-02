require 'spec_helper'

describe Hari::Entity::Serialization::DateTime do

  describe '.serialize' do
    it 'converts to date time string' do
      subject.serialize(DateTime.new(2011, 07, 01, 10, 20, 30)).should == '2011-07-01T10:20:30+00:00'
    end
  end

  describe '.desserialize' do
    it 'converts to date time' do
      subject.desserialize('2011-07-01T10:20:30').should == DateTime.new(2011, 07, 01, 10, 20, 30)
    end

    context 'when an invalid value is desserialized' do
      it 'raises an error' do
        expect { subject.desserialize('not a date time') }.to raise_error
      end
    end
  end

end
