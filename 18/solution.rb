# frozen_string_literal: true

# require "byebug"
require "set"
# require 'ruby-prof'
# require 'memory_profiler'

def parse(file)
  File.readlines(file).map(&:chomp)
end

class Cave
  def initialize(scan)
    @map = {}
    @keys_by_pos = {}
    @doors_by_pos = {}
    @doors_by_letter = {}
    scan.each.with_index(0) do |line, y|
      line.each_char.with_index(0) do |c, x|
        pos = Complex(x, y)
        @map[pos] = c
        @pos = pos if c == "@"
        @keys_by_pos[pos] = c if /[a-z]/.match?(c)
        if /[A-Z]/.match?(c)
          @doors_by_pos[pos] = c
          @doors_by_letter[c] = pos
        end
      end
    end
  end

  def show
    Range.new(*@map.keys.map(&:imag).minmax).each do |y|
      Range.new(*@map.keys.map(&:real).minmax).each do |x|
        print @map[Complex(x, y)]
      end
      puts
    end
    puts "Keys: #{@keys_by_pos}"
    puts "Doors by pos: #{@doors_by_pos}"
    puts "Doors by letter: #{@doors_by_letter}"
  end

  def wall?(pos)
    @map[pos] == "#"
  end

  def adjacent_positions(pos)
    @directions ||= [1, -1, 1i, -1i].freeze
    @adjacent_cache ||= {}
    return @adjacent_cache[pos] if @adjacent_cache.key?(pos)

    @adjacent_cache[pos] = @directions.map { |direction| pos + direction }
                                      .filter { |new_pos|  !wall?(new_pos) }
  end

  def reachable_keys(pos, keys, doors)
    visited = [pos].to_set
    positions = [[pos, 0]]

    reachable = []
    until positions.empty?
      pos, steps = positions.shift
      if keys.include?(pos)
        reachable << [pos, steps]
        next
      end

      adjacent = adjacent_positions(pos)
      # p adjacent_positions
      # byebug
      adjacent.each do |adjacent_position|
        next if visited.include?(adjacent_position) || doors.include?(adjacent_position)

        visited << adjacent_position
        positions << [adjacent_position, steps + 1]
      end
    end
    reachable
  end

  def find_keys
    keys_left = 100
    solution_steps = []
    states = [[@pos, @keys_by_pos.keys.to_set, @doors_by_pos.keys.to_set, 0]]
    until states.empty?
      pos, keys, doors, total_steps = states.shift
      if keys.size < keys_left
        keys_left = keys.size
        puts "Keys left: #{keys_left}"
      end

      if keys.empty?
        solution_steps << total_steps
        next
      end

      reachable = reachable_keys(pos, keys, doors)
      reachable.each do |key_pos, steps|
        key_letter = @keys_by_pos[key_pos]
        new_total_steps = total_steps + steps
        new_keys = keys - [key_pos]
        existing_state = states.detect { |existing_pos, existing_keys, _| existing_pos == key_pos && existing_keys == new_keys }

        add_new_state =
          if existing_state
            same_keys_steps = existing_state[3]
            new_total_steps < same_keys_steps
          else
            true
          end

        if existing_state && add_new_state
          states.delete(existing_state)
        end

        if add_new_state
          door_pos = @doors_by_letter[key_letter.upcase]
          states << [
            key_pos,
            new_keys,
            doors - [door_pos],
            new_total_steps
          ]
        end
      end
    end
    solution_steps.min
  end
end

scan = parse("test_scan4.txt")
# p scan
cave = Cave.new(scan)
cave.show

# profile the code
# RubyProf.start
#MemoryProfiler.start
steps = cave.find_keys
# result = RubyProf.stop
#report = MemoryProfiler.stop

puts "Steps: #{steps}"

# print a flat profile to text
#printer = RubyProf::FlatPrinter.new(result)
#printer.print(STDOUT)

#report.pretty_print


# run your code

