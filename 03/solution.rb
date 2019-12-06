require "set"

def parse_wires
  File.readlines("wires.txt")
end

def path(wire)
  wire.map { |move|
    direction = move[0]
    count = move[1..-1].to_i
    direction * count
  }.join
end

def move(direction, location)
  case direction
  when "R"
    [location[0] + 1, location[1]]
  when "L"
    [location[0] - 1, location[1]]
  when "U"
    [location[0], location[1] + 1]
  when "D"
    [location[0], location[1] - 1]
  else
    raise "Unknown direction #{direction}"
  end
end

def distance(p1, p2)
  (p1[0] - p2[0]).abs + (p1[1] + p2[1]).abs
end

def delay(p, coords)
  coords.index(p)
end

def total_delay(p, coords1, coords2)
  delay(p, coords1) + delay(p, coords2)
end

def coords(path)
  path.each_char.with_object([[0, 0]]) do |direction, coords|
    coords << move(direction, coords[-1])
  end
end

def intersections(coords1, coords2)
  coords1.to_set & coords2.to_set
end

def find_intersection(w1, w2)
  path1 = path(w1.split(","))
  path2 = path(w2.split(","))
  coords1 = coords(path1)
  coords2 = coords(path2)
  intersections = intersections(coords1, coords2).delete([0, 0])

  puts "Closest intersection:"
  pp intersections.map { |i| [distance([0, 0], i), i] }.min_by { |dist, i| dist }

  puts "Intersection with smallest signal delay:"
  pp intersections.map { |i| [total_delay(i, coords1, coords2), i] }.min_by { |delay, i| delay }
end

# 6, 30
# w1 = "R8,U5,L5,D3"
# w2 = "U7,R6,D4,L4"

# 159, 610
# w1 = "R75,D30,R83,U83,L12,D49,R71,U7,L72"
# w2 = "U62,R66,U55,R34,D71,R55,D58,R83"

# 135, 410
# w1 = "R98,U47,R26,D63,R33,U87,L62,D20,R33,U53,R51"
# w2 = "U98,R91,D20,R16,D67,R40,U7,R15,U6,R7"

find_intersection(w1, w2)
