def adjacent?(p)
  p[0] == p[1] ||
    p[1] == p[2] ||
    p[2] == p[3] ||
    p[3] == p[4] ||
    p[4] == p[5]
end

def increasing?(p)
  p[0] <= p[1] &&
    p[1] <= p[2] &&
    p[2] <= p[3] &&
    p[3] <= p[4] &&
    p[4] <= p[5]
end

def valid?(p)
  adjacent?(p) && increasing?(p)
end

def valid2?(p)
  repeats = []
  digits = [p[0]]
  (1..5).each do |idx|
    if p[idx] == digits[0]
      digits << p[idx]
    else
      repeats << digits
      digits = [p[idx]]
    end
  end
  repeats << digits
  # pp repeats
  repeats.any? { |ary| ary.size == 2 }
end

# p1 = [1, 1, 1, 1, 1, 1]
# p2 = [2, 2, 3, 4, 5, 0]
# p3 = [1, 2, 3, 7, 8, 9]

# puts adjacent?(p1)
# puts adjacent?(p2)
# puts adjacent?(p3)

# puts increasing?(p1)
# puts increasing?(p2)
# puts increasing?(p3)

# puts valid?(p1)
# puts valid?(p3)
# puts valid?(p2)

def next_password!(p)
  p[5] = p[5] == 9 ? 0 : p[5] + 1
  if p[5] == 0
    p[4] = p[4] == 9 ? 0 : p[4] + 1
    if p[4] == 0
      p[3] = p[3] == 9 ? 0 : p[3] + 1
      if p[3] == 0
        p[2] = p[2] == 9 ? 0 : p[2] + 1
        if p[2] == 0
          p[1] = p[1] == 9 ? 0 : p[1] + 1
          if p[1] == 0
            p[0] = p[0] == 9 ? 0 : p[0] + 1
          end
        end
      end
    end
  end
end

def find_passwords(p1, p2)
  p = p1.clone
  found1 = 0
  found2 = 0
  count = 0
  loop do
    count += 1
    valid = valid?(p)
    if valid
      found1 += 1
      found2 += 1 if valid2?(p)
    end
    # puts "Checked #{count} passwords: found #{found1} valid passwords so far" if count % 10_000 == 0
    break if p == p2

    next_password!(p)
  end
  [found1, found2]
end

p1 = [1, 2, 5, 7, 3, 0]
p2 = [5, 7, 9, 3, 8, 1]

answer1, answer2 = find_passwords(p1, p2)
puts "Part 1 answer: #{answer1}"
puts "Part 2 answer: #{answer2}"
