require 'spec_helper'

describe Hari::Node do

  let(:joao)     { TestNode.create name: 'Joao',     model_id: 25 }
  let(:teresa)   { TestNode.create name: 'Teresa',   model_id: 26 }
  let(:raimundo) { TestNode.create name: 'Raimundo', model_id: 27 }
  let(:maria)    { TestNode.create name: 'Maria',    model_id: 28 }
  let(:joaquim)  { TestNode.create name: 'Joaquim',  model_id: 29 }
  let(:lili)     { TestNode.create name: 'Lili',     model_id: 30 }

  specify 'find' do
    joao.name.should eq('Joao')
    TestNode.find('test_node#25').name.should eq('Joao')
    TestNode.find(25).name.should eq('Joao')
    TestNode.find('25').name.should eq('Joao')
  end

  describe 'queries' do
    before do
      Hari.relation! :follow, joao, teresa
      Hari.relation! :follow, joao, raimundo
      Hari.relation! :follow, joao, lili

      Hari.relation! :follow, teresa, raimundo
      Hari.relation! :follow, teresa, maria

      Hari.relation! :follow, raimundo, maria
      Hari.relation! :follow, raimundo, joaquim
    end

    it 'can has queries' do
      joao.out(:follow).count.should eq(3)
      joao.out(:follow).to_a.should eq [lili, raimundo, teresa]
      joao.out(:follow).limit(1).to_a.should eq [lili]
      joao.out(:follow).limit(2).to_a.should eq [lili, raimundo]
      joao.out(:follow).nodes_ids.to_a.should eq %w(test_node#30 test_node#27 test_node#26)
      joao.out(:follow).nodes_ids!.should eq %w(test_node#30 test_node#27 test_node#26)

      lili.out(:follow).nodes!.should eq []

      Hari.node(test_node: 25).out(:follow).to_a.should eq [lili, raimundo, teresa]
    end

    it 'can chain queries' do
      followers_following = joao.out(:follow).out(:follow).to_a
      followers_following.map(&:id).sort.should eq [raimundo, maria, joaquim].map(&:id).sort
    end
  end

  describe 'queries with pagination' do
    before do
      followings = [teresa, raimundo, maria, joaquim, lili]
      x = 5

      followings.each do |following|
        Delorean.time_travel_to x.minutes.ago do
          Hari.relation! :follow, joao, following
        end

        x += 5
      end
    end

    it 'paginates queries' do
      following = joao.out(:follow).from(15.minutes.ago.to_f).to_a
      following.map(&:id).sort.should eq [teresa, raimundo].map(&:id).sort

      following = joao.out(:follow).from(15.minutes.ago.to_f, 'down').to_a
      following.map(&:id).sort.should eq [maria, joaquim, lili].map(&:id).sort
    end

    it 'paginates chained queries' do
      Hari.relation! :follow, teresa, joao

      following = teresa.out(:follow).out(:follow).from(15.minutes.ago.to_f)
      following.to_a.map(&:id).sort.should eq [teresa, raimundo].map(&:id).sort
      following.nodes!.map(&:id).sort.should eq [teresa, raimundo].map(&:id).sort

      following = teresa.out(:follow).out(:follow).from(15.minutes.ago.to_f, 'down')
      following.to_a.map(&:id).sort.should eq [maria, joaquim, lili].map(&:id).sort
    end
  end

  describe 'queries by type' do
    before do
      Hari.relation! :follow, 'user#1', 'celeb#x'
      Hari.relation! :follow, 'user#2', 'user#1'
    end

    it 'can intersect type queries' do
      friends = Hari('user#2').out(:follow).type(:user)
      fans    = Hari('celeb#x').in(:follow).type(:user)

      fans.intersect_count(friends).should eq(1)
      friends.intersect_count(fans).should eq(1)

      fans.intersect(friends).should eq %w(1)

      Hari.relation! :follow, 'user#3', 'celeb#x'
      Hari.relation! :follow, 'user#4', 'celeb#x'
      Hari.relation! :follow, 'user#5', 'celeb#x'
      Hari.relation! :follow, 'user#6', 'celeb#x'
      Hari.relation! :follow, 'user#7', 'celeb#x'
      Hari.relation! :follow, 'user#8', 'celeb#x'

      Hari.relation! :follow, 'user#2', 'user#4'
      Hari.relation! :follow, 'user#2', 'user#5'
      Hari.relation! :follow, 'user#2', 'user#6'
      Hari.relation! :follow, 'user#2', 'user#7'

      fans.intersect(friends, 1, 3).should eq %w(6 5 4)

      fans.sort_by(friends).take(5).should eq %w(7 6 5 4 1)
    end
  end

end
