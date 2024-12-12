#!/usr/bin/env elixir

# https://adventofcode.com/2024/day/3

instructions =
  File.stream!("day-03.txt")
  |> Enum.map(fn line ->
    Regex.scan(~r/mul\((\d{1,3}),(\d{1,3})\)/, line)
    |> Enum.map(fn [_, x, y] ->
      {:mul, String.to_integer(x), String.to_integer(y)}
    end)
  end)
  |> List.flatten()

part1 =
  Enum.reduce(instructions, 0, fn {_, a, b}, acc ->
    acc + a * b
  end)

IO.inspect(part1)

defmodule Extractor do
  def instructions(string) do
    regex = ~r/
      (?<instruction>do|don't|mul)
      \(
          (?<x>\d{1,3})?(,(?<y>\d{1,3}))?
      \)
    /x

    Regex.scan(regex, string)
    |> Enum.map(fn match -> clean_named_captures(match, regex) end)
    |> Enum.map(&extract/1)
  end

  defp clean_named_captures(match, regex) do
    Regex.named_captures(regex, Enum.at(match, 0))
    |> Enum.reject(fn {_key, value} -> value == "" end)
    |> Enum.into(%{})
  end

  defp extract(%{"instruction" => "do"}), do: {:do}
  defp extract(%{"instruction" => "don't"}), do: {:dont}

  defp extract(%{"instruction" => "mul", "x" => x, "y" => y}) do
    {:mul, String.to_integer(x), String.to_integer(y)}
  end
end

{_, part2} =
  File.stream!("day-03.txt")
  |> Enum.map(&Extractor.instructions/1)
  |> List.flatten()
  |> Enum.reduce({:enabled, 0}, fn instruction, {state, acc} ->
    case instruction do
      {:do} ->
        {:enabled, acc}

      {:dont} ->
        {:disabled, acc}

      {:mul, a, b} ->
        {
          state,
          if(state === :enabled, do: acc + a * b, else: acc)
        }
    end
  end)

IO.inspect(part2)
