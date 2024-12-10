#!/usr/bin/env ruby

# https://adventofcode.com/2024/day/8

require "bundler/setup"
Bundler.require

$antennas = Hash.new { |h, k| h[k] = [] }

lines = File.readlines("#{__dir__}/day-08.txt", chomp: true)

$height = lines.count
$width = lines.first.size

lines.each_with_index do |line, row|
  line.chars.each_with_index do |ch, col|
    next if ch == "."
    $antennas[ch] << Complex(col, row)
  end
end

def inside?(a)
  a.real >= 0 && a.real < $width && a.imag >= 0 && a.imag < $height
end

def antinodes(a, b)
  d = b - a
  [a - d, b + d].select { |p| inside?(p) }
end

unique_antinodes = $antennas
  .reduce(Set.new) do |acc, (_, positions)|
    positions
      .combination(2)
      .reduce(acc) do |iacc, (a, b)|
        iacc | antinodes(a, b).to_set
      end
  end

puts unique_antinodes.count

def antinodes2(a, b)
  result = []

  d = b - a

  an = a
  while inside?(an)
    result << an
    an = an - d
  end

  an = b
  while inside?(an)
    result << an
    an = an + d
  end

  result
end

unique_antinodes2 = $antennas
  .reduce(Set.new) do |acc, (_, positions)|
    positions
      .combination(2)
      .reduce(acc) do |iacc, (a, b)|
        iacc | antinodes2(a, b).to_set
      end
  end

puts unique_antinodes2.count
