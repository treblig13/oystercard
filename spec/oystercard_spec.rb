require 'oystercard'

describe OysterCard do

  let(:oystercard)    { described_class.new }
  let(:station)       { double :station }
  let(:entry_station) { double :entry_station }
  let(:exit_station)  { double :exit_station}

  describe '#initialize' do
    it 'sets a default max limit of 1' do
      expect(oystercard.max_limit).to eq OysterCard::MAX_LIMIT
    end

    it 'sets a default balance of 0' do
      expect(oystercard.balance).to eq OysterCard::DEFAULT_BALANCE
    end

    it 'has an empty journey history' do
      expect(oystercard.journey_history).to be_empty
    end

  end

  describe '#top_up' do
    it 'Adds the top up value to the balance' do
      expect { oystercard.top_up(3) }.to change{ oystercard.balance}.by 3
    end

    it 'doesn"t allow the user to top up above card limit (£90)' do
      message = "Your balance is currently #{oystercard.balance} and your limit is #{oystercard.max_limit}"
      expect { oystercard.top_up(95) }.to raise_error message
    end

    it 'doesn"t allow the user to top up the balance above the max limit' do
      oystercard.top_up(oystercard.max_limit)
      message = "Your balance is currently #{oystercard.balance} and your limit is #{oystercard.max_limit}"
      expect { oystercard.top_up(1) }.to raise_error message
    end
  end

  describe '#touch_in' do
    context 'user has topped up above minimum fare' do
      it 'adds entry station to the journey history' do
        oystercard.top_up(1)
        oystercard.touch_in(entry_station)
        expect(oystercard.journey_history).to eq [{:departure_station => entry_station}]
      end
    end

    context 'user has not topped up' do
      it 'raises an error when a user touches in with less than the minimum fare as their balance' do
        message = 'You have insufficient funds to touch in'
        expect { oystercard.touch_in(station) }.to raise_error message
      end
    end

  end

  describe '#touch_out' do
    context 'user has topped up above minimum fare' do
      it 'adds exit station to journey history' do
        oystercard.top_up(5)
        oystercard.touch_in(entry_station)
        oystercard.touch_out(exit_station)
        expect(oystercard.journey_history).to eq [{:departure_station => entry_station}, {:arrival_station => exit_station}]
      end
    end

    context 'user has not topped up' do
      it 'deducts the minmum fare from the users balance' do
        expect { oystercard.touch_out(station) }.to change{ oystercard.balance}.by -oystercard.min_fare
      end
    end
  end

end
