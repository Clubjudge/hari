require 'spec_helper'

describe Hari::Entity::Serialization::Boolean do

  describe '.serialize, .desserialize' do
    it 'truthful values become true' do
      subject.serialize(true).should   be_true
      subject.serialize('true').should be_true
      subject.serialize('TRUE').should be_true
      subject.serialize('1').should    be_true
      subject.serialize(1).should      be_true
      subject.serialize(1.0).should    be_true
      subject.serialize('x').should    be_true
      subject.serialize('X').should    be_true
      subject.serialize('t').should    be_true
      subject.serialize('T').should    be_true
    end

    it 'untruthful values become false' do
      subject.serialize(false).should   be_false
      subject.serialize('false').should be_false
      subject.serialize('FALSE').should be_false
      subject.serialize('0').should     be_false
      subject.serialize(0).should       be_false
      subject.serialize(0.0).should     be_false
      subject.serialize('').should      be_false
      subject.serialize(' ').should     be_false
      subject.serialize(nil).should     be_false
    end
  end

end
