require 'roll_set'

describe RollSet do
  subject {
    RollSet.new('Shadow Price', 'PvP', 2050789284, traits, roll_data)
  }

  let(:traits)    {
    {
      'barrels' =>     {'t' => 9, 'c' => 2},
      'magazines' =>   {'t' => 7, 'c' => 2},
      'perks1' =>      {'t' => 12, 'c' => 1},
      'perks2' =>      {'t' => 12, 'c' => 1},
      'masterworks' => {'t' => 4, 'c' => 1}
    }
  }

  let(:roll_data) {
    {
      'name' => 'Vertical/Dark Side',
      'perks' => {
        'base' => {
          'barrels' => ['Arrowhead Brake'],
          'magazines' => ['Steady Rounds'],
          'perks1' => ['Killing Wind'],
          'perks2' => ['Headseeker', 'Moving Target', 'Kill Clip', 'Eye of the Storm'],
          'masterworks' => ['Stability MW']
        },
        'extensions' => { 
          'magazines' => ['Steady Rounds', 'Flared Magwell', 'Tactical Mag'] 
        }
      },
      # Level of indirection that allows locally-scoped 'let' blocks specify
      # roll variants per example
      'variants' => get_variants()
    }
  }

  def get_variants
    variants
  end

  describe 'wishlist formatting' do

    context 'when all base perks are used' do
      let(:variants) {
        ["🏔🌒🌒🌒🌟 Collector's Edition"]
      }
      it 'generates a wishlist' do
        gold_output = IO.read('./spec/gold_data/roll_set/when_all_base_perks_are_used_data.txt')
        expect(subject.generate_wishlist_txt()).to eq(gold_output)
      end
    end

    context 'extending' do
      
      context 'when additional perks are used' do
        let(:variants) {
          ["🏔🌒🌒🌒 CE (+magazines)"]
        }
        it 'generates a wishlist' do
          gold_output = IO.read('./spec/gold_data/roll_set/when_additional_perks_are_used_data.txt')
          expect(subject.generate_wishlist_txt()).to eq(gold_output)
        end
      end

      context 'when additional perks improperly specified' do
        let(:variants) {
          ["🏔🌒🌒🌒 CE (+whoops)"]
        }
        it 'generates a wishlist' do
          expect { subject.generate_wishlist_txt() }.to raise_error(/No extended perks are defined/)
        end
      end

    end

    context 'generalizing' do

      context 'when some base perks are not used' do
        let(:variants) {
          ["🏔🌒🌒 (*magazines, *masterworks)"]
        }
        it 'generates a wishlist' do
          gold_output = IO.read('./spec/gold_data/roll_set/when_some_base_perks_are_not_used_data.txt')
          expect(subject.generate_wishlist_txt()).to eq(gold_output)
        end
      end
  
      context 'when unused columns are improperly specified' do
        let(:variants) {
          ["🏔🌒🌒 (*whoops, *masterworks)"]
        }
        it 'generates a wishlist' do
          expect { subject.generate_wishlist_txt() }.to raise_error(/Cannot find column to generalize/)
        end
      end
    
    end

  end

end