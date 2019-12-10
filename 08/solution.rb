require "byebug"

def parse(file)
  File.readlines(file).first.chomp
end

def layers(dsn, dimx, dimy)
  pixels_per_layer = dimx * dimy
  layer_count = dsn.length / pixels_per_layer
  # puts "Parsing #{layer_count} layers..."
  layers = Array.new(layer_count) { Array.new(dimx) { Array.new(dimy, 0) } }

  dsn.each_char.with_index do |ch, idx|
    layer, pixel = idx.divmod(pixels_per_layer)
    y, x = pixel.divmod(dimx)
    #puts "#{layer}, #{x}, #{y}"
    layers[layer][x][y] = ch.to_i
  end
  layers
end

# dsn = "123456789012" # .each_char.map(&:to_i)
# dimx = 3
# dimy = 2
# layers = layers(dsn, dimx, dimy)


dsn = parse("image.txt")
dimx = 25
dimy = 6
layers = layers(dsn, dimx, dimy)

# pp layers

def count(n, layer)
  layer.flatten.count { |p| p == n }
end

def fewest_zeroes(layers)
  layers.min_by { |layer| count(0, layer) }
end

layer = fewest_zeroes(layers)
answer1 = count(1, layer) * count(2, layer)
puts "Answer 1: #{answer1}"

def combine_layers(layers, dimx, dimy)
  combined = Array.new(dimx) { Array.new(dimy, 2) }
  layers.each do |layer|
    (0..dimx - 1).each do |x|
      (0..dimy - 1).each do |y|
        combined_pixel = combined[x][y]
        layer_pixel = layer[x][y]
        combined[x][y] = layer_pixel if combined_pixel == 2
      end
    end
  end
  combined
end

combined = combine_layers(layers, dimx, dimy)

def display_image(combined, dimx, dimy)
  (0..dimy - 1).each do |y|
    (0..dimx - 1).each do |x|
      print combined[x][y] == 1 ? "*" : " "
    end
    puts
  end
end

display_image(combined, dimx, dimy)
