#!/usr/bin/env ruby

# https://adventofcode.com/2024/day/7

require "bundler/setup"
Bundler.require

equations = File
  .readlines("#{__dir__}/day-07.txt", chomp: true)
  .map do |line|
    test, numbers = line.split(":")
    test = test.to_i
    numbers = numbers.split(/\s/).drop(1).map(&:to_i)
    [test, numbers]
  end

def calibration_results(numbers)
  operators = [
    -> (a, b) { a + b },
    -> (a, b) { a * b }
  ]

  operators
    .repeated_permutation(numbers.size - 1)
    .map do |ops|
      result = numbers.first
      ops.each_with_index do |op, idx|
        result = op.call(result, numbers[idx + 1])
      end
      result
    end
end

part1 = equations
  .reduce(0) do |acc, (result, numbers)|
    if calibration_results(numbers).include?(result)
      acc + result
    else
      acc
    end
  end

puts part1

def digits(number)
  if number < 100000
    if number < 100
      return 1 if number < 10
      2
    else
      return 3 if number < 1000
      return 4 if number < 10000
      5
    end
  else
    if number < 10000000
      return 6 if number < 1000000
      7
    else
      return 8 if number < 100000000
      return 9 if number < 1000000000
      return Math.log10(b).floor + 1 if number > 9999999999
      10
    end
  end
end

def can_get_calibration_result(result, numbers)
  operators = [
    -> (a, b) { a + b },
    -> (a, b) { a * b },
    -> (a, b) { a * 10.pow(digits(b)) + b }
  ]

  operators
    .repeated_permutation(numbers.size - 1)
    .each do |ops|
      x = numbers.first
      ops.each_with_index do |op, idx|
        x = op.call(x, numbers[idx + 1])
      end

      if x == result
        return true
      end
    end
  false
end

part2 = equations
  .reduce(0) do |acc, (result, numbers)|
    if can_get_calibration_result(result, numbers)
      acc + result
    else
      acc
    end
  end

puts part2
