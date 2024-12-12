#!/usr/bin/env elixir

# https://adventofcode.com/2024/day/6

defmodule MapParser do
  def parse(file_path) do
    {obstacles, size, starting_point} =
      file_path
      |> File.stream!()
      |> Enum.map(&String.trim/1)
      |> Enum.with_index()
      |> Enum.reduce({MapSet.new(), {nil, nil}, nil}, fn {line, y},
                                                         {obstacles, {width, _}, starting_point} ->
        {obstacles, starting_point} = parse_line(line, y, obstacles, starting_point)
        {obstacles, {width || String.length(line), y + 1}, starting_point}
      end)

    {{obstacles, size}, starting_point}
  end

  defp parse_line(line, y, obstacles, starting_point) do
    line
    |> String.graphemes()
    |> Enum.with_index()
    |> Enum.reduce({obstacles, starting_point}, fn
      {"#", x}, {obstacles, starting_point} ->
        {MapSet.put(obstacles, {x, y}), starting_point}

      {"^", x}, {obstacles, _} ->
        {obstacles, {x, y}}

      _, acc ->
        acc
    end)
  end
end

defmodule MapWalker do
  def outside?({width, height}, {x, y}) do
    x < 0 || x >= width || y < 0 || y >= height
  end

  def facing_obstacle?(obstacles, position) do
    {point, _} = move(position)
    MapSet.member?(obstacles, point)
  end

  def move({{x, y}, {dx, dy}}) do
    {{x + dx, y + dy}, {dx, dy}}
  end

  def turn_right({point, direction}), do: {point, next_direction(direction)}

  defp next_direction({0, -1}), do: {1, 0}
  defp next_direction({1, 0}), do: {0, 1}
  defp next_direction({0, 1}), do: {-1, 0}
  defp next_direction({-1, 0}), do: {0, -1}
end

defmodule DistinctPositionsCounter do
  def count(map, {point, _} = position) do
    loop(map, position, MapSet.new([point]))
  end

  defp loop({obstacles, size} = map, {point, _} = position, visited) do
    cond do
      MapWalker.outside?(size, point) ->
        visited

      MapWalker.facing_obstacle?(obstacles, position) ->
        loop(
          map,
          MapWalker.turn_right(position),
          visited
        )

      true ->
        loop(
          map,
          MapWalker.move(position),
          MapSet.put(visited, point)
        )
    end
  end
end

{map, starting_point} = MapParser.parse("day-06.txt")

visited_points = DistinctPositionsCounter.count(map, {starting_point, {0, -1}})

IO.inspect(MapSet.size(visited_points))

defmodule CycleDetector do
  def cycle?(map, position) do
    loop(map, position, MapSet.new())
  end

  defp loop({obstacles, size} = map, {point, _} = position, visited) do
    cond do
      MapWalker.outside?(size, point) ->
        false

      MapSet.member?(visited, position) ->
        true

      MapWalker.facing_obstacle?(obstacles, position) ->
        loop(
          map,
          MapWalker.turn_right(position),
          visited
        )

      true ->
        loop(
          map,
          MapWalker.move(position),
          MapSet.put(visited, position)
        )
    end
  end
end

defmodule AsyncReducer do
  def parallel_reduce(collection, initial, reducer_fn, chunk_size \\ 128) do
    collection
    |> Enum.chunk_every(chunk_size)
    |> Enum.map(&async_reduce_chunk(&1, initial, reducer_fn))
    |> Enum.map(&Task.await(&1, :infinity))
  end

  defp async_reduce_chunk(chunk, initial, reducer_fn) do
    Task.async(fn -> Enum.reduce(chunk, initial, reducer_fn) end)
  end
end

{obstacles, size} = map

part2 =
  MapSet.delete(visited_points, starting_point)
  |> AsyncReducer.parallel_reduce(0, fn possible_cycle_obstacle, cycled_count ->
    obstacles = MapSet.put(obstacles, possible_cycle_obstacle)

    if CycleDetector.cycle?({obstacles, size}, {starting_point, {0, -1}}) do
      cycled_count + 1
    else
      cycled_count
    end
  end)
  |> Enum.sum()

IO.inspect(part2)
