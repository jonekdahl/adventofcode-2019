require "byebug"

def parse_program
  File.readlines("program.txt").first.split(",").map(&:to_i)
end

class Computer
  def initialize(program)
    @program = program
  end

  def run(input = nil)
    @memory = @program.clone
    # @memory[1] = noun
    # @memory[2] = verb
    @ip = 0
    @input = input
    until opcode == 99
      execute_instruction
    end
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

  def read(param_index)
    mode = mode(param_index)
    source_address =
      if mode == POSITION_MODE
        @memory[@ip + param_index]
      elsif mode == IMMEDIATE_MODE
        @ip + param_index
      else
        raise "Unknown mode #{mode}"
      end
    @memory[source_address]
  end

  def write(param_index, value)
    mode = mode(param_index)
    target_index =
      if mode == POSITION_MODE
        @memory[@ip + param_index]
      elsif mode == IMMEDIATE_MODE
        @ip + param_index
      else
        raise "Unknown mode #{mode}"
      end
    puts "write #{value} to address #{target_index}"
    @memory[target_index] = value
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
      raise "Input was never defined" unless @input
      write(1, @input)
    when 4
      output = read(1)
      puts "Output: #{output}"
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
    else
      raise "unknown opcode #{opcode} at ip #{@ip}"
    end

    unless ip_moved
      @ip += 1 + OPCODES[opcode][:param_count]
    end
  end
end

program = parse_program
computer = Computer.new(program)
computer.run(5)
