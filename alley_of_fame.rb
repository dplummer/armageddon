require 'faraday'
require 'nokogiri'
require 'cgi/cookie'
require 'json'

require_relative 'player'
require_relative 'clan'

class AlleyOfFame
  attr_reader :csrf

  def initialize
    vanilla = Faraday.get("http://worldoftanks.com/clanwars/eventmap/alley/#wot&ag_tab=players&ag_search=&ag_perpage=25&ag_type=players&ag_page=0")
    @csrf = CGI::Cookie.parse(vanilla.headers['set-cookie'])['csrftoken'].first
  end

  def get_page_of_players(page_num)
    conn = Faraday.new(url: "http://worldoftanks.com/clanwars/eventmap/alley/ratings/?page=#{page_num}&page_size=100")
    response = conn.get do |req|
      req.headers['X-CSRFToken'] = csrf
      req.headers['Accept'] = 'application/json, text/javascript, */*; q=0.01'
      req.headers['X-Requested-With'] = 'XMLHttpRequest'
    end

    data = JSON.parse(response.body)['users_info']
    data.map do |player|
      Player.new(position: player['position'],
                 name: player['user'],
                 clan: player['clan_tag'],
                 fame_points: player['glory_points'])
    end
  end

  def fetch_players
    players = []

    25.times do |n|
      players.concat(get_page_of_players(n))
    end

    players.sort_by(&:position).take(2500)
  end

  def fetch_clans
    conn = Faraday.new(url: 'http://worldoftanks.com/clanwars/eventmap/ratings/search_clans_rating/?page=0&page_size=50&season_filter=current_season')

    response = conn.get do |req|
      req.headers['X-CSRFToken'] = csrf
      req.headers['Accept'] = 'application/json, text/javascript, */*; q=0.01'
      req.headers['X-Requested-With'] = 'XMLHttpRequest'
    end

    data = JSON.parse(response.body)['clans_info']
    data.map do |player|
      Clan.new(position: player['rating_position'],
               name: player['clan_name'],
               tag: player['clan_tag'],
               fame_points: player['victory_points_custom'])
    end
  end
end
