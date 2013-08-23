require 'spec_helper'

describe Hari::Entity::Serialization do

  describe '#to_json' do
    it 'serializes instance to json' do
      model = TestEntity.new(name: 'Ze',
                             birth: Date.new(1986, 01, 23),
                             points: '200',
                             preferences: { soccer: 100, rugby: 30 },
                             friends_ids: [1, 2, 3])

      model.to_json.should  == '{"id":null,"created_at":null,"updated_at":null,' +
        '"name":"Ze","country":"US","birth":"1986-01-23","points":200,' +
        '"preferences":{"soccer":100,"rugby":30},"friends_ids":[1,2,3],"male":false}'
    end
  end

  describe '.from_json' do
    it 'desserializes instance from json' do
      model = TestEntity.from_json('{"name":"Ze","birth":"1986-01-23","points":200,' +
        '"preferences":{"soccer":100,"rugby":30},"friends_ids":[1,2,3],"male":true}')

      model.name.should == 'Ze'
      model.birth.should == Date.new(1986, 01, 23)
      model.points.should == 200
      model.preferences.should eq('soccer' => 100, 'rugby' => 30)
      model.friends_ids.should eq [1, 2, 3]
      model.male.should be_true
      model.male?.should be_true
    end
  end

end
