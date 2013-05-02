require 'spec_helper'

describe Hari::Entity::Repository do

  specify '.create, .find' do
    model = TestModel.create(name: 'Ze', birth: '2012-04-20', points: '300')
    model.id.should be

    found = TestModel.find(model.id)
    found.birth.year.should == 2012
    found.birth.month.should == 4
    found.birth.day.should == 20
    found.points.should == 300
    found.name.should == 'Ze'

    model2 = TestModel.create(name: 'Jo', birth: '2009-03-21', points: '404')

    founds = TestModel.find(model.id, model2.id)
    founds.size.should == 2
  end

end
