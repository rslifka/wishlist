require 'roll_set'

class V2Generator

  def generate_toc_link(roll_data)
    activities = roll_data['activities']
    weapon_name = roll_data['name']
    weapon_link = weapon_name.downcase.gsub(/'/,'').gsub(/\//,'').gsub(/,/,'').gsub(/\./,'').gsub(/\W/,'-')

    activity_links = activities.map do |a|
      activity_name = a['name']
      link = "#{weapon_name.downcase} / #{activity_name.downcase} / Overview".gsub(/'/,'').gsub(/\//,'').gsub(/,/,'').gsub(/\./,'').gsub(/\W/,'-')
      "[#{activity_name}](##{link})"
    end
    "* [#{weapon_name}](##{weapon_link}) (#{activity_links.join(', ')})"
  end

  def generate_roll(roll_data)
    weapon_name = roll_data['name']
    gunsmith_link = "https://d2gunsmith.com/w/#{roll_data['item_id']}"
    overview = roll_data['overview']

    StringIO.new.tap do |output|

      output.puts("# #{weapon_name}")
      output.puts("*For all possible perks, check out **#{weapon_name}** over on [d2gunsmith.com](#{gunsmith_link})*")
      output.puts
      output.puts(overview)

      roll_data['activities'].each do |a|
        output.puts("### #{weapon_name} / #{a['name']} / Overview")
        output.puts(a['overview'])
        a['roll_sets'].each do |rs_data|
          rs = RollSet.new(weapon_name, a['name'], roll_data['item_id'], roll_data['traits'], rs_data)
          output.puts(rs.generate_thoughts_txt())
        end
      end

    end.string
  end

  def generate_wishlist(roll_data)
    StringIO.new.tap do |output|
      roll_data['activities'].each do |a|
        a['roll_sets'].each do |rs_data|
          rs = RollSet.new('', a['name'], roll_data['item_id'], roll_data['traits'], rs_data)
          output.puts(rs.generate_wishlist_txt())
        end
      end
    end.string
  end

end