#!/usr/bin/env elixir

# https://adventofcode.com/2024/day/2

reports =
  File.stream!("day-02.txt")
  |> Enum.map(fn line ->
    line
    |> String.split()
    |> Enum.map(&String.to_integer/1)
  end)

safe_increasing_report = fn report ->
  Enum.chunk_every(report, 2, 1, :discard)
  |> Enum.all?(fn [a, b] ->
    a < b && b - a <= 3
  end)
end

safe_decreasing_report = fn report ->
  Enum.chunk_every(report, 2, 1, :discard)
  |> Enum.all?(fn [a, b] ->
    a > b && a - b <= 3
  end)
end

safe_report = fn report ->
  safe_increasing_report.(report) || safe_decreasing_report.(report)
end

part1 =
  Enum.reduce(reports, 0, fn report, acc ->
    if safe_report.(report), do: acc + 1, else: acc
  end)

IO.inspect(part1)

reports_with_one_level_removed = fn report ->
  report
  |> Enum.with_index(fn _, idx ->
    List.delete_at(report, idx)
  end)
end

part2 =
  Enum.reduce(reports, 0, fn
    report, acc ->
      case safe_report.(report) do
        true ->
          acc + 1

        _ ->
          at_least_one_safe =
            reports_with_one_level_removed.(report)
            |> Enum.reduce(false, fn report, safe ->
              safe || safe_report.(report)
            end)

          if at_least_one_safe, do: acc + 1, else: acc
      end
  end)

IO.inspect(part2)
