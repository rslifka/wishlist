require 'roll'

describe Roll do
  
  let(:item_id)   { 2050789284 }
  let(:fq_name)   { "(PvP) Vertical/Dark Side 🏔🌒🌒🌒🌟 Collector's Edition" }
  let(:roll_name) { "🏔🌒🌒🌒🌟 Collector's Edition" }
  let(:traits)    {
    {
      'barrels' =>     {'t' => 9, 'c' => 2},
      'magazines' =>   {'t' => 7, 'c' => 2},
      'perks1' =>      {'t' => 12, 'c' => 1},
      'perks2' =>      {'t' => 12, 'c' => 1},
      'masterworks' => {'t' => 4, 'c' => 1}
    }
  }
  let(:perks) {
    {
      'barrels' => ['Arrowhead Brake'],
      'magazines' => ['Steady Rounds'],
      'perks1' => ['Killing Wind'],
      'perks2' => ['Headseeker', 'Moving Target', 'Kill Clip', 'Eye of the Storm'],
      'masterworks' => ['Stability MW']
    }
  }

  describe '#wishlist_txt' do

    context 'when all perks have preferences' do
      it 'should generate a DIM-style wishlist block' do
        gold_output = IO.read('./spec/gold_data/roll_wishlist_all_data.txt')
        r = Roll.new(item_id, fq_name, roll_name, traits, perks)
        expect(r.wishlist_txt()).to eq(gold_output)
      end
    end

    context 'when some perks have no preferences' do
      let(:fq_name) {'(PvP) Vertical/Dark Side 🏔🌒🌒 (*magazines, *masterworks)'}
      let(:roll_name) {'🏔🌒🌒 (*magazines, *masterworks)'}
      before do
        perks['magazines'].clear
        perks['masterworks'].clear
      end
      it 'should generate a DIM-style wishlist block' do
        gold_output = IO.read('./spec/gold_data/roll_wishlist_some_data.txt')
        r = Roll.new(item_id, fq_name, roll_name, traits, perks)
        expect(r.wishlist_txt()).to eq(gold_output)
      end
    end

  end

  describe '#probability' do

    context 'when all perks have preferences' do
      it 'calculates the probability of a roll' do
        r = Roll.new(item_id, fq_name, roll_name, traits, perks)
        expect(r.probability().round(5)).to eq(0.04409)
      end
    end

    context 'when some perks have no preferences' do
      before do
        perks['magazines'].clear
        perks['masterworks'].clear
      end
      it 'calculates the probability of a roll' do
        r = Roll.new(item_id, fq_name, roll_name, traits, perks)
        expect(r.probability().round(5)).to eq(0.61728)
      end
    end

  end

end