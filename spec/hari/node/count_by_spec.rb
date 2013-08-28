require 'spec_helper'

describe 'Count by' do

  let!(:lisbon) { Hari city: 10 }

  let! :concerts do
    concerts = 15.times.map do |i|
      concert = Hari(concert: i + 1)
      lisbon.out(:host) << concert
    end
  end

  before do
    Delorean.time_travel_to 1.hour.ago do
      (5..7).each do |i|
        followers_count = i * 3

        followers_count.times do
          Hari(user: SecureRandom.hex(3)).out(:follow) << Hari(concert: i)
        end
      end
    end

    (8..12).each do |i|
      followers_count = i * 3

      followers_count.times do
        Hari(user: SecureRandom.hex(3)).out(:follow) << Hari(concert: i)
      end
    end
  end

  it 'brings elements in a relation ordered by count of other relation' do
    concerts_in_lisbon = lisbon.out(:host).type(:concert)
    concerts_with_count = concerts_in_lisbon.count_by(:in, :follow, :user)

    concerts_with_count.size.should eq(15)
    concerts_with_count[0].should eq ['concert#12', 36]
    concerts_with_count[1].should eq ['concert#11', 33]
    concerts_with_count[2].should eq ['concert#10', 30]
    concerts_with_count[3].should eq ['concert#9',  27]
    concerts_with_count[4].should eq ['concert#8',  24]
    concerts_with_count[5].should eq ['concert#7',  21]
    concerts_with_count[6].should eq ['concert#6',  18]
    concerts_with_count[7].should eq ['concert#5',  15]
  end

  it 'brings elements in a relation ordered by a partial count of other relation' do
    concerts_in_lisbon = lisbon.out(:host).type(:concert)

    concerts_in_lisbon.count_by(:in, :follow, :user, from: 1.hour.ago).tap do |concerts|
      concerts.size.should eq(15)
      concerts.select { |i, c| c == 0 }.size.should eq(10)
      concerts[0].should eq ['concert#12', 36]
      concerts[1].should eq ['concert#11', 33]
      concerts[2].should eq ['concert#10', 30]
      concerts[3].should eq ['concert#9',  27]
      concerts[4].should eq ['concert#8',  24]
    end
  end

end
