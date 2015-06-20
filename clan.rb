class Clan
  LICENSES = [
    100,
    100,
    100,
    85,
    60,
    60,
    45,
    45,
    45,
    30,
    30,
    30
  ].concat([15] * 18)

  attr_reader :tag, :name, :position, :fame_points, :licenses
  attr_accessor :used

  def initialize(params = {})
    @position = params[:position]
    @name = params[:name]
    @tag = params[:tag]
    @fame_points = params[:fame_points]
    @licenses = LICENSES[position - 1] || 0
    @used = 0
  end

  def unused
    licenses - used
  end

  def give_players_tanks(players)
    players = players.take(licenses)
    players.select! {|player| player.position < 1001} if position > 3
    players.each(&:licenced!)
    self.used = players.length
    players
  end
end
