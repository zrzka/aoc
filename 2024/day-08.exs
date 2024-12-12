#!/usr/bin/env elixir

# https://adventofcode.com/2024/day/8

defmodule CityMapParser do
  def parse(file_path) do
    file_path
    |> File.stream!()
    |> Enum.map(&String.trim/1)
    |> Enum.with_index()
    |> Enum.reduce({Map.new(), {nil, nil}}, fn {line, y}, {antennas, {width, _}} ->
      {parse_line(line, y, antennas), {width || String.length(line), y + 1}}
    end)
  end

  defp parse_line(line, y, antennas) do
    line
    |> String.graphemes()
    |> Enum.with_index()
    |> Enum.reduce(antennas, fn
      {".", _}, antennas ->
        antennas

      {ch, x}, antennas ->
        antennas
        |> Map.update(ch, [{x, y}], &[{x, y} | &1])
    end)
  end
end

defmodule CityMap do
  def inside?({width, height}, {x, y}) do
    x >= 0 && x < width && y >= 0 && y < height
  end

  def antinodes(size, {x1, y1}, {x2, y2}) do
    dx = x2 - x1
    dy = y2 - y1

    [
      {x1 - dx, y1 - dy},
      {x2 + dx, y2 + dy}
    ]
    |> Enum.filter(&CityMap.inside?(size, &1))
  end

  def antinodes2(size, {x, y}, {dx, dy} = direction) do
    next = {x + dx, y + dy}

    if CityMap.inside?(size, next) do
      [{x, y} | antinodes2(size, next, direction)]
    else
      [{x, y}]
    end
  end
end

{antennas, size} = CityMapParser.parse("day-08.txt")

antinodes =
  Enum.reduce(antennas, MapSet.new(), fn {_, positions}, acc ->
    Enum.flat_map(positions, fn a ->
      Enum.map(positions, fn b ->
        if a != b, do: {a, b}, else: nil
      end)
    end)
    |> Enum.filter(& &1)
    |> Enum.map(fn {a, b} -> CityMap.antinodes(size, a, b) end)
    |> List.flatten()
    |> Enum.reduce(acc, &MapSet.put(&2, &1))
  end)

IO.inspect(MapSet.size(antinodes))

defmodule Combination do
  def combine([]), do: []

  def combine(list) when is_list(list) do
    list
    |> Enum.with_index()
    |> Enum.flat_map(fn {a, ai} ->
      list
      |> Enum.with_index()
      |> Enum.map(fn {b, bi} ->
        # It's better to compare indexes as we can have two equal
        # elements at different positions we want to combine too.
        if ai != bi, do: {a, b}, else: nil
      end)
    end)
    |> Enum.filter(& &1)
  end
end

antinodes =
  Enum.reduce(antennas, MapSet.new(), fn {_, positions}, acc ->
    positions
    |> Combination.combine()
    |> Enum.map(fn {{x1, y1}, {x2, y2}} ->
      [
        {{x1, y1}, {x1 - x2, y1 - y2}},
        {{x2, y2}, {x2 - x1, y2 - y1}}
      ]
      |> Enum.map(fn {point, delta} ->
        CityMap.antinodes2(size, point, delta)
      end)
      |> List.flatten()
    end)
    |> List.flatten()
    |> Enum.reduce(acc, &MapSet.put(&2, &1))
  end)

IO.inspect(MapSet.size(antinodes))
