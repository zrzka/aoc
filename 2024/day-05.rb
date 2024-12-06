#!/usr/bin/env ruby

# https://adventofcode.com/2024/day/5

require "bundler/setup"
Bundler.require

rules = Hash.new { |h, k| h[k] = Set.new }
updates = []

File
  .new("#{__dir__}/day-05.txt")
  .each_line do |line|
    if line.include?("|")
      a, b = line.split("|").map(&:to_i)
      rules[a].add(b)
    elsif line.include?(",")
      updates << line.split(",").map(&:to_i)
    end
  end

def correct_order(pages_to_print, rules)
  printed_pages = Set.new

  pages_to_print
    .each do |page_to_print|
      if printed_pages.intersect?(rules[page_to_print])
        return false
      end

      printed_pages.add(page_to_print)
    end

  true
end

def middle_page_number(pages_to_print)
  pages_to_print[(pages_to_print.size / 2.0).floor]
end

part1 = updates
  .reduce(0) do |acc, pages_to_print|
    if correct_order(pages_to_print, rules)
      acc + middle_page_number(pages_to_print)
    else
      acc
    end
  end

puts part1

def fix_order(pages_to_print, rules)
  fixed = []

  pages_to_print
    .each do |page_to_print|
      index = rules[page_to_print]
        .reduce(fixed.size) do |idx, before_page|
          [idx, fixed.index(before_page) || fixed.size].min
        end

      fixed.insert(index, page_to_print)
    end

  fixed
end

part2 = updates
  .reject { |pages_to_print| correct_order(pages_to_print, rules) }
  .reduce(0) do |acc, pages_to_print|
    acc + middle_page_number(fix_order(pages_to_print, rules))
  end

puts part2
