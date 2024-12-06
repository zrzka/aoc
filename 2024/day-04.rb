#!/usr/bin/env ruby

# https://adventofcode.com/2024/day/4

require "bundler/setup"
Bundler.require

matrix = File.readlines("#{__dir__}/day-04.txt", chomp: true).map(&:chars)

height = matrix.size
width = matrix.first.size

xmas = "XMAS".chars
rxmas = xmas.reverse

part1 = width.times.to_a
  .product(height.times.to_a)
  .reduce(0) do |acc, (x, y)|
    [
      [0, 0,   1, 0], # Horizontal
      [0, 0,   1, 1], # Diagonal TL -> BR
      [0, 0,   0, 1], # Vertical
      [3, 0,  -1, 1]  # Diagonal TR -> BL
    ].reduce(acc) do |wacc, (ox, oy, dx, dy)|
      window = xmas.size.times.map { |i| matrix.at(y + oy + i * dy)&.at(x + ox + i * dx) }
      (window == xmas || window == rxmas) ? wacc + 1 : wacc
    end
  end

puts part1

part2 = (1...width - 1).to_a
  .product((1...height - 1).to_a)
  .reduce(0) do |acc, (x, y)|
    unless matrix[y][x] == "A"
      next acc
    end

    tl = matrix[y - 1][x - 1]
    tr = matrix[y - 1][x + 1]
    bl = matrix[y + 1][x - 1]
    br = matrix[y + 1][x + 1]

    [tl, tr, bl, br].sort == %w[M M S S] && tl != br ? acc + 1 : acc
  end

puts part2
