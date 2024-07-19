require 'ruby2d'

set background: '#D4F4DD', title: 'snake'

set fps_cap: 20
SQUARE_SIZE = 20
GRID_WIDHT = Window.width / SQUARE_SIZE
GRID_HEIGHT = Window.height / SQUARE_SIZE

INITIAL_HEIGHT = rand(Window.height / SQUARE_SIZE)
INITIAL_WIDTH = rand(Window.width / SQUARE_SIZE)
# MOVE_DIRECTION = @body.push(set_coordinates())

class Snake
  def initialize
    @body = [[INITIAL_WIDTH,INITIAL_HEIGHT], [INITIAL_WIDTH,INITIAL_HEIGHT+1], [INITIAL_WIDTH,INITIAL_HEIGHT+2], [INITIAL_WIDTH,INITIAL_HEIGHT+3]]
    @direction = "down"
    @growing = false
  end

  def draw
    @body.each do |ref|
      Square.new(x: ref[0]*SQUARE_SIZE, y: ref[1]*SQUARE_SIZE, size: SQUARE_SIZE-1, color: '#17BEBB')
    end
  end

  def move
    @body.shift unless @growing

    puts @body.length
    case @direction
    when 'down', 's' then
      @body.push(set_coordinates(head[0], head[1]+1))
    when 'up', 'w' then
      @body.push(set_coordinates(head[0], head[1]-1))
    when 'left', 'a' then
      @body.push(set_coordinates(head[0]-1, head[1]))
    when 'right', 'd' then
      @body.push(set_coordinates(head[0]+1, head[1]))
    end
    @growing = false
  end

  def head
    @body.last
  end

  def set_direction new_direction
    return unless can_change_direction? new_direction
    @direction = new_direction
  end

  def set_coordinates x, y
    [x % GRID_WIDHT, y % GRID_HEIGHT]
  end

  def can_change_direction? new_direction
    case new_direction
    when 'down', 's' then
      @direction != 'up'
    when 'up', 'w' then
      @direction != 'down'
    when 'left', 'a' then
      @direction != 'right'
    when 'right', 'd' then
      @direction != 'left'
      
    end
  end

  def grow
    @growing = true
  end

  def x
    head[0]
  end

  def y
    head[1]
  end

  def auto_hit?
    @body.length != @body.uniq.length
  end

  def pause_match
   @game.set_paused if @game.is_playing?
  end
end

class Match
  def initialize
    @score = 0
    @ball_x = rand(GRID_WIDHT)
    @ball_y = rand(GRID_HEIGHT)
    @finished = false
    @started = false
    @paused = false
  end

  def draw
    if @finished
      Text.new("Your score was: #{@score}. Press ENTER to star a new game", x: 50, y: 220, color: 'black')
    else
      Text.new("Score: #{@score}", color: 'black')
    end
    Square.new(x: @ball_x*SQUARE_SIZE, y: @ball_y*SQUARE_SIZE, size: SQUARE_SIZE, color: '#D62246')
  end

  def hit_ball? x, y
    @ball_x == x && @ball_y == y
  end

  def set_hit
    @score += 1
    @ball_x = rand(GRID_WIDHT)
    @ball_y = rand(GRID_HEIGHT)
  end

  def finish_game
    @finished = true
  end

  def finished?
    @finished
  end

  def started?
    @started
  end

  def pause?
    @pause
  end

  def set_pause new_value
    @pause = new_value
  end

  def set_started new_value
    @started = new_value
  end
  
end

snake = Snake.new
match = Match.new

update do
  if match.started?
    if match.pause?
    clear
      Text.new("Press ENTER resume playing", x: 165, y: 220, color: 'black')
      snake.draw
    else
      clear
      snake.draw
      unless match.finished?
        snake.move
      end
    
      match.draw
    
      if match.hit_ball? snake.x, snake.y
        match.set_hit
        snake.grow
      end
    
      if snake.auto_hit?
        match.finish_game
      end
    end

  else
    clear
    Text.new("Press ENTER to start a new game", color: 'black')
  end
end

on :key_down do |event|
  snake.set_direction event.key if ['up','down','left','right', 'w', 'a', 's', 'd'].include? event.key
  if event.key == 'return' && match.finished?
    snake = Snake.new
    match = Match.new
  end

  if event.key == 'return' && !match.started?
    match.set_started true 
  end

  if event.key == 'return' && match.pause?
    match.set_pause false 
    match.set_started true
  end

  if event.key == 'space' && !match.pause?
    match.set_pause true 
  end
end

show
