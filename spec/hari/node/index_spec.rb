require 'spec_helper'

describe Hari::Node::Index do

  class Customer < Hari::Node
    property :name
    property :status, index: true
    property :age,    index: true
  end

  let!(:joao)  { Customer.create name: 'Joao',  status: 'pending', age: '20' }

  let!(:maria) { Customer.create name: 'Maria', status: 'pending', age: '21' }

  let! :antonio do
    Delorean.time_travel_to 20.minutes.ago do
      Customer.create name: 'Antonio', status: 'pending', age: '21'
    end
  end

  let! :joaquim do
    Delorean.time_travel_to 40.minutes.ago do
      Customer.create name: 'Joaquim', status: 'pending', age: '21'
    end
  end

  let! :manoel do
    Delorean.time_travel_to 40.minutes.ago do
      Customer.create name: 'Manoel',  status: 'active',  age: '21'
    end
  end

  describe '.find_by' do
    subject { Customer.find_by :status, 'pending' }

    context 'without from' do
      its(:count) { should eq(4) }

      it 'retrieves elements in right order' do
        subject.to_a.map(&:name).should eq %w(Maria Joao Antonio Joaquim)
      end

      context 'and with pagination' do
        let(:query_paginated) { subject.limit(0, 2) }

        specify 'count' do
          query_paginated.count.should eq(4)
        end

        specify 'data' do
          query_paginated.to_a.map(&:name).should eq %w(Maria Joao)
        end
      end
    end

    context 'with from' do
      let(:query) { subject.from(25.minutes.ago) }

      specify 'count' do
        query.count.should eq(3)
      end

      specify 'data' do
        query.to_a.map(&:name).should eq %w(Maria Joao Antonio)
      end

      context 'and pagination' do
        let(:query_paginated) { query.limit(0, 2) }

        specify 'count' do
          query_paginated.count.should eq(3)
        end

        specify 'data' do
          query_paginated.to_a.map(&:name).should eq %w(Maria Joao)
        end
      end
    end
  end

  describe '.where' do
    subject { Customer.where status: 'pending', age: '21' }

    context 'without from' do
      its(:count) { should eq(3) }

      it 'retrieves elements in right order' do
        subject.to_a.map(&:name).should eq %w(Maria Antonio Joaquim)
      end

      context 'and with pagination' do
        let(:query_paginated) { subject.limit(0, 2) }

        specify 'count' do
          query_paginated.count.should eq(3)
        end

        specify 'data' do
          query_paginated.to_a.map(&:name).should eq %w(Maria Antonio)
        end
      end
    end

    context 'with from' do
      let(:query) { subject.from(25.minutes.ago) }

      specify 'count' do
        query.count.should eq(2)
      end

      specify 'data' do
        query.to_a.map(&:name).should eq %w(Maria Antonio)
      end

      context 'and pagination' do
        let(:query_paginated) { query.limit(0, 1) }

        specify 'count' do
          query_paginated.count.should eq(2)
        end

        specify 'data' do
          query_paginated.to_a.first.name.should eq 'Maria'
        end
      end

    end
  end

  describe 'from a type query' do
    before do
      joao.out(:follow) << antonio
      joao.out(:follow) << maria
      joao.out(:follow) << joaquim
      joao.out(:follow) << manoel
    end

    it 'queries users' do
      active = joao.out(:follow).type(:customer).where(status: 'active')
      active.count.should eq(1)
      active.to_a.first.name.should eq('Manoel')
    end
  end

end
