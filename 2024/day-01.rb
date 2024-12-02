#!/usr/bin/env ruby

# https://adventofcode.com/2024/day/1

require "bundler/setup"
Bundler.require

first, second = File
  .foreach("#{__dir__}/day-01.txt")
  .map { |x| x.split.map(&:to_i) }
  .transpose

first_sorted = first.sort
second_sorted = second.sort

part1 = first_sorted.zip(second_sorted)
  .reduce(0) { |acc, (a, b)| acc + (a - b).abs }

puts part1

first_occurences = first.tally
second_occurences = second.tally

part2 = first_occurences
  .reduce(0) { |acc, (k, v)| acc + v * k * second_occurences.fetch(k, 0) }

puts part2
