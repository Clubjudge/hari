require 'spec_helper'

describe Hari::Node do
  let(:joao)     { TestNode.create name: 'Joao',     model_id: 25 }
  let(:teresa)   { TestNode.create name: 'Teresa',   model_id: 26 }
  let(:raimundo) { TestNode.create name: 'Raimundo', model_id: 27 }
  let(:maria)    { TestNode.create name: 'Maria',    model_id: 28 }
  let(:joaquim)  { TestNode.create name: 'Joaquim',  model_id: 29 }
  let(:lili)     { TestNode.create name: 'Lili',     model_id: 30 }

  before do
    Hari.redis.flushdb
    Hari::Relationship.create :follow, joao, teresa
    Hari::Relationship.create :follow, joao, raimundo
    Hari::Relationship.create :follow, joao, lili
    Hari::Relationship.create :follow, teresa,   raimundo
    Hari::Relationship.create :follow, teresa,   maria
    Hari::Relationship.create :follow, raimundo, maria
    Hari::Relationship.create :follow, raimundo, joaquim
  end

  it 'can has queries' do
    joao.out(:follow).to_a.should eq [lili, raimundo, teresa]
    joao.out(:follow).limit(1).to_a.should eq [lili]
    joao.out(:follow).limit(2).to_a.should eq [lili, raimundo]

    Hari.node(test_node: 25).out(:follow).to_a.should eq [lili, raimundo, teresa]
  end

  it 'can chain queries' do
    followers_following = joao.out(:follow).out(:follow).to_a
    followers_following.map(&:id).sort.should eq [raimundo, maria, joaquim].map(&:id).sort
  end
end
