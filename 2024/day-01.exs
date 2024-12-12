#!/usr/bin/env elixir

# https://adventofcode.com/2024/day/1

{first, second} =
  File.stream!("day-01.txt")
  |> Enum.map(fn line ->
    [a, b] = String.split(line)
    {String.to_integer(a), String.to_integer(b)}
  end)
  |> Enum.unzip()

part1 =
  Enum.zip(Enum.sort(first), Enum.sort(second))
  |> Enum.reduce(0, fn {a, b}, acc ->
    acc + abs(a - b)
  end)

IO.inspect(part1)

second_freq = Enum.frequencies(second)

part2 =
  Enum.frequencies(first)
  |> Enum.reduce(0, fn {k, v}, acc ->
    acc + k * v * Map.get(second_freq, k, 0)
  end)

IO.inspect(part2)
