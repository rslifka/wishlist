require 'probability'
require 'roll'

TRAIT_PRETTY = [
  {:key => 'barrels',     :label => 'Barrels'},
  {:key => 'magazines',   :label => 'Mags   '},
  {:key => 'perks1',      :label => 'Perks 1'},
  {:key => 'perks2',      :label => 'Perks 2'},
  {:key => 'masterworks', :label => 'MWorks '},
]

class RollSet

  def initialize(activity_name, item_id, traits, roll_data)
    @activity_name = activity_name
    @item_id = item_id
    @traits = traits
    @name = roll_data['name']
    @overview = roll_data['overview']
    @base_perks = roll_data['perks']['base']
    @extended_perks = roll_data['perks']['extensions']
    @variants = roll_data['variants']

    @rolls = []
    create_rolls
  end

  def to_s
    output = StringIO.new
    @rolls.each do |r|
      output.puts(r)
    end
    output.string
  end

  def generate_thoughts_txt
    StringIO.new.tap do |output|
      output.puts("#### **#{@name}**")
      
      output.puts(@overview)

      output.puts('```')
      TRAIT_PRETTY.each do |t|
        good_perks = @base_perks[t[:key]].length
        total_perks = @traits[t[:key]]['t']
        available_slots = @traits[t[:key]]['c']

        p = Probability.column_probability(good_perks, total_perks, available_slots)
        
        message = (p.to_i == 1) ? '*' : (@base_perks[t[:key]].join(', '))
        output.puts("  #{t[:label]} [%3d%%]: #{message}" % [p * 100])
      end
      output.puts('```')
      
      output.puts('| Variant | Chance |')
      output.puts('|:-|-:|')
      @rolls.each do |r|
        output.puts("| #{r.roll_name} | %0.1f%% |" % [r.probability()])
      end
    end.string
  end

  def generate_wishlist_txt
    StringIO.new.tap do |output|
      @rolls.each do |r|
        output.puts(r.wishlist_txt())
      end
    end.string
  end

  private

  def create_rolls
    @variants.each do |roll_name|
      # puts "Working on variant; activity=#{@activity_name}, weapon=#{@name}, roll=#{roll_name}'"

      perks = Marshal.load(Marshal.dump(@base_perks))
    
      additions = roll_name.scan(/\+\w+/).map{|p| p.sub('+','')}
      additions.each do |a|
        perks[a] = Marshal.load(Marshal.dump(@extended_perks[a]))
      end

      removals = roll_name.scan(/-\w+/).map{|p| p.sub('-','')}
      removals.each do |r|
        # TODO: Backfill test
        raise "Cannot find base perk to remove '#{r}'; activity=#{@activity_name}, weapon=#{@name}, roll=#{roll_name}'" unless perks.has_key?(r)
        perks[r].clear
      end

      fq_name = "(%s) %s %s" % [@activity_name, @name, roll_name]

      @rolls << Roll.new(@item_id, fq_name, roll_name, @traits, perks)
    end
  end

end