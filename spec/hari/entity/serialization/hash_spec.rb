require 'spec_helper'

describe Hari::Entity::Serialization::Hash do

  specify '.serialize' do
    subject.serialize(nil).should eq({})
    subject.serialize('').should  eq({})
    subject.serialize(a: 1, b: 2).should eq(a: 1, b: 2)

    struct = OpenStruct.new(a: 1, b: 2)
    subject.serialize(struct).should eq(a: 1, b: 2)

    expect { subject.serialize('notahash') }.to raise_error
  end

end
