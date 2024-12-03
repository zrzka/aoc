#!/usr/bin/env ruby

# https://adventofcode.com/2024/day/3

require "bundler/setup"
Bundler.require

instructions = File.read("#{__dir__}/day-03.txt")

part1 = instructions
  .scan(/mul\((\d{1,3}),(\d{1,3})\)/)
  .reduce(0) do |acc, match|
    a, b = match.map(&:to_i)
    acc + a * b
  end

puts part1

part2 = instructions
  .scan(/(do(?:n't)?\(\)|mul\((\d{1,3}),(\d{1,3})\))/)
  .reduce([true, 0]) do |acc, match|
    instruction, a, b = match

    if instruction == "do()"
      [true, acc[1]]
    elsif instruction == "don't()"
      [false, acc[1]]
    elsif acc[0]
      [true, acc[1] + a.to_i * b.to_i]
    else
      acc
    end
  end

puts part2[1]
