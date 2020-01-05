require "byebug"
require "set"

def parse(file)
  File.readlines(file).first.split(",").map(&:to_i).map(&:freeze)
end

class Computer
  def initialize(program)
    @program = program
  end

  def run(inputs, outputs)
    init_memory
    @ip = 0
    @relative_base = 0
    @inputs = inputs
    @outputs = outputs
    until opcode == 99
      execute_instruction
    end
  end

  def init_memory
    @memory = Array.new(@program.size * 10, 0)
    @program.each.with_index { |ch, idx| @memory[idx] = ch }
  end

  def result
    @memory[0]
  end

  OPCODES = {
    1 => {param_count: 3},
    2 => {param_count: 3},
    3 => {param_count: 1},
    4 => {param_count: 1},
    5 => {param_count: 2},
    6 => {param_count: 2},
    7 => {param_count: 3},
    8 => {param_count: 3},
    9 => {param_count: 1},
    99 => {param_count: 0},
  }

  def opcode
    @memory[@ip] % 100
  end

  def mode(param_index)
    raise "Index must be positive (#{param_index})" unless param_index.positive?

    modes = @memory[@ip] / 100
    modes / 10**(param_index - 1) % 10
  end

  POSITION_MODE = 0
  IMMEDIATE_MODE = 1
  RELATIVE_MODE = 2

  def resolve_address(param_index)
    mode = mode(param_index)
    case mode
    when POSITION_MODE
      @memory[@ip + param_index]
    when IMMEDIATE_MODE
      @ip + param_index
    when RELATIVE_MODE
      @memory[@ip + param_index] + @relative_base
    else
      raise "Unknown mode #{mode}"
    end
  end

  def read(param_index)
    source_address = resolve_address(param_index)
    @memory[source_address]
  end

  def write(param_index, value)
    target_address = resolve_address(param_index)
    # puts "write #{value} to address #{target_address}"
    @memory[target_address] = value
  end

  def execute_instruction
    opcode = opcode()
    ip_moved = false
    # byebug
    case opcode
    when 1
      write(3, read(1) + read(2))
    when 2
      write(3, read(1) * read(2))
    when 3
      input = @inputs.pop
      write(1, input)
      # puts "Input: #{input}"
    when 4
      output = read(1)
      @outputs << output
      # puts "Output: #{output}"
    when 5
      unless read(1).zero?
        @ip = read(2)
        ip_moved = true
      end
    when 6
      if read(1).zero?
        @ip = read(2)
        ip_moved = true
      end
    when 7
      read(1) < read(2) ? write(3, 1) : write(3, 0)
    when 8
      read(1) == read(2) ? write(3, 1) : write(3, 0)
    when 9
      @relative_base += read(1)
    else
      raise "unknown opcode #{opcode} at ip #{@ip}"
    end

    unless ip_moved
      @ip += 1 + OPCODES[opcode][:param_count]
    end
  end
end

class Vacuum
  def initialize(computer)
    @computer = computer
    @grid = {}
  end

  LEFT = Complex(-1, 0)
  RIGHT = Complex(1, 0)
  UP = Complex(0, -1)
  DOWN = Complex(0, 1)

  DIRECTIONS = {
    '<' => LEFT,
    '>' => RIGHT,
    '^' => UP,
    'v' => DOWN,
  }

  TURN_LEFT = {
    LEFT => DOWN,
    DOWN => RIGHT,
    RIGHT => UP,
    UP => LEFT,
  }

  TURN_RIGHT = {
    LEFT => UP,
    UP => RIGHT,
    RIGHT => DOWN,
    DOWN => LEFT,
  }

  def run
    inputs = Queue.new
    outputs = Queue.new

    Thread.new do
      puts "Starting vacuum control program"
      @computer.run(inputs, outputs)
      puts "Control program halted"
      outputs << :control_program_halted
    end

    pos = Complex(0, 0)
    loop do
      ascii = outputs.pop
      break if ascii == :control_program_halted

      if ascii == 10
        pos = Complex(0, pos.imag + 1)
      else
        chr = ascii.chr
        @grid[pos] = chr
        direction = DIRECTIONS[chr]
        if direction
          @vacuum_direction = direction
          @vacuum_pos = pos
        end
        pos += 1
      end
    end
  end

  def run_program(main, sub_a, sub_b, sub_c)
    inputs = Queue.new
    outputs = Queue.new

    Thread.new do
      puts "Starting vacuum control program"
      @computer.run(inputs, outputs)
      puts "Control program halted"
      outputs << :control_program_halted
    end

    prog = main.each_char.map(&:itself).join(',') + "\n"
    prog += sub_a.map { |direction, steps| "#{direction},#{steps}" }.join(',') + "\n"
    prog += sub_b.map { |direction, steps| "#{direction},#{steps}" }.join(',') + "\n"
    prog += sub_c.map { |direction, steps| "#{direction},#{steps}" }.join(',') + "\n"
    prog += "n\n"
    byebug
    pp prog

    prog.each_char { |char| inputs << char.ord }

    result = []
    loop do
      ascii = outputs.pop
      break if ascii == :control_program_halted

      result << ascii
    end
    result
  end

  def at(pos)
    @grid[pos]
  end

  def scaffold?(pos)
    at(pos) == '#'
  end

  def intersection?(pos)
    scaffold?(pos) &&
    scaffold?(pos + RIGHT) &&
    scaffold?(pos + LEFT) &&
    scaffold?(pos + UP) &&
    scaffold?(pos + DOWN)
  end

  def show
    Range.new(*@grid.keys.map(&:imag).minmax).each do |y|
      Range.new(*@grid.keys.map(&:real).minmax).each do |x|
        print @grid[Complex(x, y)]
      end
      puts
    end
  end

  def intersections
    intersections = []
    (1..@grid.keys.map(&:imag).max - 1).each do |y|
      (1..@grid.keys.map(&:real).max - 1).each do |x|
        pos = Complex(x, y)
        intersections << pos if intersection?(pos)
      end
    end
    intersections
  end

  def path
    turn = nil
    path = []
    steps = 0
    loop do
      if scaffold?(@vacuum_pos + @vacuum_direction)
        steps += 1
        @vacuum_pos += @vacuum_direction
      elsif scaffold?(@vacuum_pos + TURN_LEFT[@vacuum_direction])
        if steps.positive?
          path << [turn, steps]
          steps = 0
        end
        turn = 'L'
        @vacuum_direction = TURN_LEFT[@vacuum_direction]
      elsif scaffold?(@vacuum_pos + TURN_RIGHT[@vacuum_direction])
        if steps.positive?
          path << [turn, steps]
          steps = 0
        end
        turn = 'R'
        @vacuum_direction = TURN_RIGHT[@vacuum_direction]
      else
        if steps.positive?
          path << [turn, steps]
          steps = 0
        end
        break
      end
    end
    path
  end
end

program = parse("program.txt")
computer = Computer.new(program)

robot = Vacuum.new(computer)
robot.run

puts "Ran vacuum"
robot.show
intersections = robot.intersections
sum = intersections.map { |p| p.real * p.imag }.sum
puts "Sum of intersections: #{sum}"

path = robot.path
pp path

# above path manually simplified
sub_a = [
 ["R", 6],
 ["L", 10],
 ["R", 8],
]

sub_b = [
 ["R", 8],
 ["R", 12],
 ["L", 8],
 ["L", 8],
]

sub_c = [
 ["L", 10],
 ["R", 6],
 ["R", 6],
 ["L", 8],
]

main = "ABABCABCAC"

program[0] = 2
computer = Computer.new(program)
robot = Vacuum.new(computer)
dust = robot.run_program(main, sub_a, sub_b, sub_c)
p "Dust collected: #{dust}"
