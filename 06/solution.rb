require "byebug"

def parse(file)
  File.readlines(file).map { |line| line.chomp.split(")") }
end

orbits = parse("orbits.txt")
# pp orbits

def create_orbit_tree(orbits, body)
  orbiters = orbits.select { |b, orbiter| b == body }.map { |_b, orbiter| orbiter }
  [body, orbiters.map { |o| create_orbit_tree(orbits, o) }]
end

orbit_tree = create_orbit_tree(orbits, "COM")
# pp orbit_tree

def sum_orbits(tree, depth = 0)
  depth + tree[1].sum { |t| sum_orbits(t, depth + 1) }
end

puts "Total orbits: #{sum_orbits(orbit_tree)}"

def path_to(tree, body, path_so_far = [])
  # puts "visiting #{tree[0]} looking for #{body}"
  if tree[0] == body
    path_so_far + [body]
  else
    orbiter_trees = tree[1]
    if orbiter_trees.empty?
      nil
    else
      orbiter_trees.find do |t|
        path = path_to(t, body, path_so_far + [tree[0]])
        break path if path
      end
    end
  end
end

you_path = path_to(orbit_tree, "YOU")
san_path = path_to(orbit_tree, "SAN")

# pp you_path
# pp san_path

def distance(p1, p2)
  if p1[0] == p2[0]
    distance(p1[1..-1], p2[1..-1])
  else
    # pp p1
    # pp p2
    p1.length + p2.length - 2
  end
end

puts "Distance YOU -> SAN: #{distance(you_path, san_path)}"
