require 'spec_helper'

describe Hari::Entity::Repository do

  specify '.create, .find' do
    model = TestEntity.create(name: 'Ze', birth: '2012-04-20', points: '300')
    model.id.should be

    found = TestEntity.find(model.id)
    found.birth.year.should == 2012
    found.birth.month.should == 4
    found.birth.day.should == 20
    found.points.should == 300
    found.name.should == 'Ze'

    model2 = TestEntity.create(name: 'Jo', birth: '2009-03-21', points: '404')

    founds = TestEntity.find(model.id, model2.id)
    founds.size.should == 2

    model2.update_attributes birth: '2001-01-01', points: '403', friends_ids: [1, 3, 4]

    found = TestEntity.find(model2.id)
    found.birth.year.should eq(2001)
    found.birth.month.should eq(1)
    found.birth.day.should eq(1)
    found.points.should eq(403)
    found.friends_ids.should eq [1, 3, 4]

    found.update_attributes friends_ids: [4, 5, 6]

    TestEntity.find(found.id).friends_ids.should eq [4, 5, 6]

    found.update_attribute :name, 'Joe'

    TestEntity.find(found.id).name.should eq('Joe')
  end

end
