class Player
  attr_reader :position, :name, :clan, :fame_points, :free, :licenced

  def initialize(params = {})
    @position = params[:position]
    @name = params[:name]
    @clan = params[:clan]
    @fame_points = params[:fame_points]
    @free = false
    @licenced = false
  end

  def free!
    @free = true
  end

  def licenced!
    @licenced = true
  end
end
