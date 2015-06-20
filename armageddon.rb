require 'pry'

require_relative 'alley_of_fame'

class Armageddon
  attr_reader :alley_of_fame

  def initialize
    @alley_of_fame = AlleyOfFame.new
  end

  def players
    @players ||= alley_of_fame.fetch_players
  end

  def clans
    @clans ||= alley_of_fame.fetch_clans
  end

  def assign_tanks_by_licenses
    players_by_clan = players.index_by(&:clan)
    clans.each do |clan|
      clan.give_players_tanks(players_by_clan.fetch(clan.tag, []))
    end
  end

  def process!
    assign_tanks_by_licenses
    distribute_extra_tanks
  end

  def distribute_extra_tanks
    extras = players.reject(&:licenced).sort_by(&:position)
    extras.take(available).each(&:free!)
    extras
  end

  def available
    1000 - clans.map(&:used).inject(&:+)
  end

  def write_output
    process!

    File.open('alley.md', 'w') do |file|
      file.puts "A total of #{players.count(&:free)} players will receive a free tank outside of what the top 30 clans get"
      file.puts "Created at #{Time.now}"
      file.puts ""

      file.puts "Position | Clan | Licenses | Used | Unused"
      file.puts "-------- | ---- | -------- | ---- | ------"
      clans.take(30).each do |clan|
        file.puts [clan.position, "`#{clan.tag}`", clan.licenses, clan.used, clan.unused].join(' | ')
      end

      file.puts ""
      file.puts "Position | Name | Clan | Points | Free Tank?"
      file.puts "-------- | ---- | ---- | ------ | ----------"
      players.take(1000).each do |player|
        file.puts [player.position,
                   "`#{player.name}`",
                   "`#{player.clan}`",
                   player.fame_points,
                   player.licenced ? 'Licenced' : (player.free ? 'Free' : 'Gold')].join(' | ')
      end
    end
    puts "done"
    puts players.select {|player| player.clan == 'FELIX' && player.free}.map(&:name).join(', ')
  end
end

class Array
  def index_by(&block)
    each_with_object(Hash.new {|h,k| h[k] = []}) do |obj, acc|
      acc[block.call(obj)] << obj
    end
  end
end
