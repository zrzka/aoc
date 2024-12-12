#!/usr/bin/env elixir

# https://adventofcode.com/2024/day/7

equations =
  File.stream!("day-07.txt")
  |> Enum.map(&String.trim/1)
  |> Enum.map(fn line ->
    [test, numbers] = String.split(line, ":")

    numbers =
      numbers
      |> String.trim()
      |> String.split(~r/\s/)
      |> Enum.map(&String.to_integer/1)

    {String.to_integer(test), numbers}
  end)

defmodule Permutation do
  def repeated(list, 0) when is_list(list), do: [[]]

  def repeated(list, n) when is_list(list) and n > 0 do
    for elem <- list,
        perm <- repeated(list, n - 1) do
      [elem | perm]
    end
  end
end

defmodule Calibration do
  def calculate(operations, numbers) do
    operations
    |> Permutation.repeated(length(numbers) - 1)
    |> Enum.map(fn operations ->
      [first | rest] = numbers

      rest
      |> Enum.zip(operations)
      |> Enum.reduce(first, fn {number, operation}, acc ->
        operation.(acc, number)
      end)
    end)
  end
end

operations = [
  &Kernel.+/2,
  &Kernel.*/2
]

part1 =
  equations
  |> Enum.reduce(0, fn {test, numbers}, acc ->
    results = Calibration.calculate(operations, numbers)
    if Enum.member?(results, test) do
      acc + test
    else
      acc
    end
  end)

IO.inspect(part1)

defmodule DigitCounter do
  def count(n) when is_integer(n) and n == 0, do: 1

  def count(n) when is_integer(n) and n > 0 do
    :math.log10(n) |> trunc() |> Kernel.+(1)
  end
end

defmodule Concatenator do
  def concatenate(a, b) when is_integer(a) and is_integer(b) do
    a * :math.pow(10, DigitCounter.count(b)) + b |> trunc()
  end
end

operations = operations ++ [&Concatenator.concatenate/2]

part2 =
  equations
  |> Enum.reduce(0, fn {test, numbers}, acc ->
    results = Calibration.calculate(operations, numbers)
    if Enum.member?(results, test) do
      acc + test
    else
      acc
    end
  end)

IO.inspect(part2)
