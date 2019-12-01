def parse_masses
  File.readlines("modules.txt").map(&:to_i)
end

def required_fuel_simple(mass)
  mass.fdiv(3).floor - 2
end

def total_fuel_simple(masses)
  masses.sum { |m| required_fuel_simple(m) }
end

masses = parse_masses

# puts "Module count: #{parse_masses.size}"
# puts "Fuel(12): #{required_fuel_simple(12)}"
# puts "Fuel(14): #{required_fuel_simple(14)}"
# puts "Fuel(1969): #{required_fuel_simple(1969)}"
# puts "Fuel(100756): #{required_fuel_simple(100756)}"
puts "Total fuel (simple): #{total_fuel_simple(masses)}"

def required_fuel(mass)
  fuel = required_fuel_simple(mass)
  if fuel.negative?
    return 0
  else
    return fuel + required_fuel(fuel)
  end
end

def total_fuel(masses)
  masses.sum { |m| required_fuel(m) }
end

# puts "Fuel(14): #{required_fuel(14)}"
# puts "Fuel(1969): #{required_fuel(1969)}"
# puts "Fuel(100756): #{required_fuel(100756)}"
puts "Total fuel: #{total_fuel(masses)}"
