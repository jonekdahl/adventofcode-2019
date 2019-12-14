require "byebug"

def parse(file)
  File.readlines(file).map(&:chomp)
end

def sign(n)
  n == 0 ? 1 : n.abs / n
end

class Map
  def initialize(lines)
    @lines = lines
    @xmax = lines.first.length - 1
    @ymax = lines.length - 1
  end

  def at(x, y)
    @lines[y][x]
  end

  def asteroid_at?(x, y)
    at(x, y) == "#"
  end

  def asteroids
    return @asteroids if @asteroids

    @asteroids = []
    (0..@ymax).each do |y|
      (0..@xmax).each do |x|
        @asteroids << [x, y] if asteroid_at?(x, y)
      end
    end
    @asteroids
  end

  def position(x, y)
    [x, y]
  end

  def positions_between(a1, a2)
    # puts "Between #{a1} and #{a2}"
    delta_y = a2[1] - a1[1]
    delta_x = a2[0] - a1[0]
    if delta_x == 0
      step_x = 0
      step_y = delta_y.positive? ? 1 : -1
    else
      k = Rational(delta_y.abs, delta_x.abs)
      # puts "k: #{k}"
      step_x = k.denominator * sign(delta_x)
      step_y = k.numerator * sign(delta_y)
    end
    # puts "step_x: #{step_x}"
    # puts "step_y: #{step_y}"
    positions = []
    step = 0
    loop do
      step += 1
      position = position(a1[0] + step * step_x, a1[1] + step * step_y)
      # byebug
      break if position == a2
      # pp position
      positions << position
    end
    positions
  end

  def can_see?(a1, a2)
    can_see = if a1 == a2
      # puts "Same position"
      false
    else
      positions = positions_between(a1, a2)
      if positions.empty?
        # puts "No positions between"
        true
      else
        # puts "No asteroids between"
        positions.none? { |p| asteroid_at?(*p) }
      end
    end
  end

  def detectable_asteroids(from)
    asteroids.count do |asteroid|
      can_see = can_see?(from, asteroid)
      # puts "Between #{from} and #{asteroid}, can see: #{can_see}"
      can_see
    end
  end

  def max_visisble
    asteroids.map { |a| [a, detectable_asteroids(a)] }.sort_by { |a, count| count }.last
  end

  def distance(p1, p2)
    (p1[0] - p2[0]).abs + (p1[1] - p2[1]).abs
  end

  TWOPI = 6.2831853071795865

  def angle(a, b)
     # y axis increases downwards, by inverting the delta y calculation we get 0 degrees at twelve o'clock
    theta = Math.atan2(b[0] - a[0], a[1] - b[1])
    theta.negative? ? theta + TWOPI : theta
  end

  def vaporize(laser)
    vaporized = []
    targets = asteroids.reject { |a| a[0] == laser[0] && a[1] == laser[1] }
    asteroids_by_angle = targets.group_by { |a| angle(laser, a) }
    asteroids_by_angle.transform_values! { |asteroids| asteroids.sort_by { |a| distance(laser, a) } }
    asteroids_by_angle = asteroids_by_angle.sort
    angle_idx = 0
    loop do
      break if vaporized.size == targets.size

      unless asteroids_by_angle[angle_idx][1].empty?
        vaporized_asteroid = asteroids_by_angle[angle_idx][1].shift
        vaporized << vaporized_asteroid
      end
      angle_idx = (angle_idx + 1) % asteroids_by_angle.size
    end
    vaporized
  end
end

# program = "109,1,204,-1,1001,100,1,100,1008,100,16,101,1006,101,0,99".split(",").map(&:to_i)
# program = "1102,34915192,34915192,7,4,7,99,0".split(",").map(&:to_i)
# program = "104,1125899906842624,99".split(",").map(&:to_i)

lines = parse("map.txt")
# lines = parse("large_test_map1.txt")
map = Map.new(lines)

laser_position = map.max_visisble.first
vaporized = map.vaporize(laser_position)
puts "The 200th asteroid to be vaporized is #{vaporized[199]}"

# vaporized.each.with_index(1) do |vaporized_asteroid, idx|
#   puts "The #{idx}th asteroid to be vaporized is #{vaporized_asteroid}"
# end

