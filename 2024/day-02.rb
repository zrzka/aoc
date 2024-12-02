#!/usr/bin/env ruby

# https://adventofcode.com/2024/day/2

require "bundler/setup"
Bundler.require

def safe_increasing_report?(report)
  report.each_cons(2).all? { |a, b| a < b && b - a <= 3 }
end

def safe_decreasing_report?(report)
  report.each_cons(2).all? { |a, b| a > b && a - b <= 3 }
end

def safe_report?(report)
  safe_increasing_report?(report) || safe_decreasing_report?(report)
end

part1 = File
  .foreach("#{__dir__}/day-02.txt")
  .reduce(0) { |acc, line| acc + (safe_report?(line.split.map(&:to_i)) ? 1 : 0) }

puts part1

part2 = File
  .foreach("#{__dir__}/day-02.txt")
  .reduce(0) do |acc, line|
    report = line.split.map(&:to_i)

    if safe_report?(report)
      acc + 1
    else
      safe = (0...report.size)
        .reduce(false) do |acc, idx|
          acc || safe_report?(report[0...idx] + report[idx + 1..-1])
        end
      acc + (safe ? 1 : 0)
    end
  end

puts part2
