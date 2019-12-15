require "byebug"

class Position
  attr_accessor :x, :y, :z

  def initialize(x, y, z)
    @x = x
    @y = y
    @z = z
  end

  def to_s
    "<x=#{@x}, y=#{@y}, z=#{@z}>"
  end
  alias inspect to_s
end

class Moon
  attr_accessor :position

  def initialize(position)
    @position = position
    @velocity = Position.new(0, 0, 0)
  end

  def gravity(n)
    n == 0 ? 0 : n.abs / n
  end

  def apply_gravity(other_moon)
    # pp [self.position, other_moon.position]
    # pp @velocity
    @velocity.x += gravity(other_moon.position.x - @position.x)
    @velocity.y += gravity(other_moon.position.y - @position.y)
    @velocity.z += gravity(other_moon.position.z - @position.z)
    # pp @velocity
  end

  def apply_velocity
    @position.x += @velocity.x
    @position.y += @velocity.y
    @position.z += @velocity.z
  end

  def total_energy
    potential_energy * kinetic_energy
  end

  def potential_energy
    @position.x.abs + @position.y.abs + @position.z.abs
  end

  def kinetic_energy
    @velocity.x.abs + @velocity.y.abs + @velocity.z.abs
  end

  def to_s
    "<pos=#{@position}, vel=#{@velocity}>"
  end
  alias inspect to_s
end

def parse(file)
  File.readlines(file).map do |line|
    line.chomp[1..-2].split(",").map(&:strip).map { |v| v[2..-1].to_i }
  end
end

def simulate
  moons = parse("moons.txt").map { |coords| Moon.new(Position.new(*coords)) }

  (0..).each do |index|
    # p "After #{index} steps:"
    # pp moons
    break if index == 1000

    moons.permutation(2).each { |m1, m2| m1.apply_gravity(m2) }
    moons.each(&:apply_velocity)
  end
  p "Total energy: #{moons.sum(&:total_energy)}"
end

simulate
