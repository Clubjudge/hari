require 'spec_helper'

describe Hari::Serialization do

  class TestSerialization
    include Hari::Serialization

    property :name
    property :male, type: Boolean
  end

  it 'adds serialization skills to class' do
    object = TestSerialization.new(name: 'Chuck', male: true)
    object.to_hash.should eq('name' => 'Chuck', 'male' => true)
    object.attribute(:name).should eq('Chuck')
    object.has_attribute?(:name).should be_true
    object.has_attribute?(:nome).should be_false

    object.to_json.should eq('{"name":"Chuck","male":true}')

    from_json = TestSerialization.from_json('{"name":"Chuck","male":true}')
    from_json.name.should eq('Chuck')
    from_json.male.should be_true
    from_json.male?.should be_true
  end
end
