def parse_program
  File.readlines("program.txt").first.split(",").map(&:to_i)
end

#puts "Program size: #{program.size}"

class Computer
  def initialize(program)
    @program = program
  end

  def run(noun, verb)
    @memory = @program.clone
    @memory[1] = noun
    @memory[2] = verb
    @ip = 0
    until opcode == 99
      execute_instruction
    end
  end

  def result
    @memory[0]
  end

  def opcode
    @memory[@ip]
  end

  def execute_instruction
    op1_value = @memory[@memory[@ip + 1]]
    op2_value = @memory[@memory[@ip + 2]]
    target_index = @memory[@ip + 3]
    case opcode
    when 1
      result = op1_value + op2_value
      # puts "#{op1_value} + #{op2_value} = #{result}, store in #{target_index}"
      @memory[target_index] = result
      @ip += 4
    when 2
      result = op1_value * op2_value
      # puts "#{op1_value} * #{op2_value} = #{result}, store in #{target_index}"
      @memory[target_index] = result
      @ip += 4
    else
      raise "unknown opcode #{opcode} at ip #{@ip}"
    end
  end
end

program = parse_program
computer = Computer.new(program)
#p1 = [1,1,1,4,99,5,6,0,99]
#computer.run(p1)

computer.run(12, 2)
puts "Answer 1: #{computer.result}"

def search(computer, target_value)
  (0..100).each do |noun|
    (0..100).each do |verb|
      computer.run(noun, verb)
      #puts "#{noun}, #{verb}: #{computer.result}"
      if computer.result == target_value
        puts "Found target value #{target_value} at noun #{noun}, verb #{verb}"
        puts "Answer 2: #{100 * noun + verb}"
        return
      end
    end
  end
end

search(computer, 19_690_720)
