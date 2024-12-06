#!/usr/bin/env ruby

# https://adventofcode.com/2024/day/6

require "bundler/setup"
Bundler.require

DIRECTIONS = [
  0-1i, 1+0i, 0+1i, -1+0i
]

matrix = File.readlines("#{__dir__}/day-06.txt", chomp: true).map(&:chars)

$height = matrix.size
$width = matrix.first.size
$obstacles = Set.new
$start = nil

$width.times do |x|
  $height.times do |y|
    case matrix[y][x]
    when "#"
      $obstacles << Complex(x, y)
    when "^"
      $start = Complex(x, y)
    end
  end
end

def inside_map?(pos)
  pos.real.between?(0, $width - 1) && pos.imag.between?(0, $height - 1)
end

def find_positions_out
  direction = 0
  pos = $start

  positions = Set.new

  while inside_map?(pos)
    positions.add(pos)

    if $obstacles.include?(pos + DIRECTIONS[direction])
      direction = (direction + 1) % DIRECTIONS.size
      next
    end

    pos += DIRECTIONS[direction]
  end

  positions
end

positions = find_positions_out
part1 = positions.size
puts part1

def cycle?(obstacle)
  obstacles = $obstacles.dup
  obstacles.add(obstacle)

  direction = 0
  pos = $start

  positions = Set.new

  while inside_map?(pos)
    positions.add([pos, direction])

    if obstacles.include?(pos + DIRECTIONS[direction])
      direction = (direction + 1) % DIRECTIONS.size
      next
    end

    pos += DIRECTIONS[direction]
    if positions.include?([pos, direction])
      return true
    end
  end

  false
end

positions.delete($start)
part2 = positions
  .filter_map { |x| cycle?(x) }
  .count
puts part2
