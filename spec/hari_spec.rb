require 'spec_helper'

describe Hari do

  let(:model) { TestNode.new(id: '1') }

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

end
