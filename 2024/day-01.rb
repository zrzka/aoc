#!/usr/bin/env ruby

# https://adventofcode.com/2024/day/1

require "bundler/setup"
Bundler.require

first, second = File
  .foreach("#{__dir__}/day-01.txt")
  .map { |x| x.split.map(&:to_i) }
  .transpose

first.sort!
second.sort!

result = first.zip(second)
  .reduce(0) { |acc, (a, b)| acc + (a - b).abs }

puts result
