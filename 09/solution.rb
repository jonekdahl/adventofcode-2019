require "byebug"

def parse(file)
  File.readlines(file).first.split(",").map(&:to_i).map(&:freeze)
end

class Computer
  def initialize(program)
    @program = program
  end

  def run(input = nil)
    init_memory()
    @ip = 0
    @relative_base = 0
    @input = input
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

# program = "109,1,204,-1,1001,100,1,100,1008,100,16,101,1006,101,0,99".split(",").map(&:to_i)
# program = "1102,34915192,34915192,7,4,7,99,0".split(",").map(&:to_i)
# program = "104,1125899906842624,99".split(",").map(&:to_i)

program = parse("program.txt")
computer = Computer.new(program)
computer.run(2)
