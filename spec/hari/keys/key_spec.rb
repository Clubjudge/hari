require 'spec_helper'

describe Hari::Keys::Key do

  let(:node) { Hari.node user: 10 }
  subject    { node.list :friends }

  specify { subject.instance_of? Hari::Keys::Key }

  before { subject.add 1 }

  specify '#exists? + #delete!' do
    subject.exists?.should be_true

    subject.delete!

    subject.exists?.should be_false
  end

  specify '#type' do
    subject.type.should eq('list')
  end

  specify '#expire + #persist + #ttl' do
    subject.expire 80 # ms
    (subject.ttl.to_i < 80).should be_true

    sleep 0.1

    subject.exists?.should be_false

    subject.add 12
    subject.expire 100
    subject.persist

    sleep 0.2

    subject.exists?.should be_true
  end

end
