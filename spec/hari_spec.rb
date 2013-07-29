require 'spec_helper'

describe Hari do

  let(:model) { TestNode.create name: 'Tom', model_id: '1' }

  describe '.node_key' do
    specify { Hari.node_key('user#1').should eq('user#1') }
    specify { Hari.node_key(user: 1).should eq('user#1') }
    specify { Hari.node_key(model).should eq('test_node#1') }
  end

  describe '.node_id' do
    specify { Hari.node_id('user#1').should eq('1') }
    specify { Hari.node_id('user' => '1').should eq('1') }
    specify { Hari.node_id(model).should eq('1') }
  end

  describe '.node_type' do
    specify { Hari.node_type('user#1').should eq('user') }
    specify { Hari.node_type('user' => '1').should eq('user') }
    specify { Hari.node_type(model).should eq('test_node') }
  end

  specify '.node' do
    node = Hari.node(user: 1)

    node.model_id.should eq(1)
    node.node_type.should eq('user')

    node = Hari(user: 1)

    node.model_id.should eq(1)
    node.node_type.should eq('user')
  end

  specify '.relation!' do
    Hari.relation! :follow, 'user#1', 'user#2'

    Hari(user: 1).out(:follow).nodes_ids!.should eq %w(user#2)
  end

  specify '.remove_relation!' do
    Hari.relation! :follow, 'user#6', 'user#9'
    Hari.remove_relation! :follow, 'user#6', 'user#9'

    Hari(user: 1).out(:follow).nodes_ids!.should be_empty
  end

end
