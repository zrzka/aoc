#!/usr/bin/env elixir

# https://adventofcode.com/2024/day/4

defmodule Point do
  def create(x, y), do: {x, y}

  def add({x1, y1}, {x2, y2}), do: {x1 + x2, y1 + y2}
end

matrix =
  File.stream!("day-04.txt")
  |> Enum.map(&String.trim/1)
  |> Enum.map(&String.graphemes/1)

directions = [
  {0, 0, 1, 0},
  {0, 0, 1, 1},
  {0, 0, 0, 1},
  {3, 0, -1, 1}
]

xmas = String.graphemes("XMAS")
rxmas = String.graphemes("SAMX")

matrix_element = fn matrix, {x, y} ->
  case Enum.at(matrix, y, nil) do
    nil ->
      nil

    row ->
      Enum.at(row, x, nil)
  end
end

matrix_elements = fn matrix, {x, y}, {ox, oy, dx, dy}, count ->
  0..(count - 1)
  |> Enum.map(fn i ->
    matrix_element.(matrix, {x + ox + dx * i, y + oy + dy * i})
  end)
end

part1 =
  Enum.reduce(Enum.with_index(matrix), 0, fn {row, y}, row_acc ->
    Enum.reduce(0..(Enum.count(row) - 1), row_acc, fn x, col_acc ->
      Enum.reduce(directions, col_acc, fn direction, acc ->
        elements = matrix_elements.(matrix, {x, y}, direction, Enum.count(xmas))

        if elements == xmas || elements == rxmas do
          acc + 1
        else
          acc
        end
      end)
    end)
  end)

IO.inspect(part1)

part2 =
  Enum.reduce(Enum.with_index(matrix), 0, fn {row, y}, row_acc ->
    Enum.reduce(Enum.with_index(row), row_acc, fn {el, x}, acc ->
      case el do
        "A" ->
          tl = matrix_element.(matrix, {x - 1, y - 1})
          tr = matrix_element.(matrix, {x + 1, y - 1})
          bl = matrix_element.(matrix, {x - 1, y + 1})
          br = matrix_element.(matrix, {x + 1, y + 1})

          sorted = Enum.sort([tl, tr, bl, br])

          if sorted === String.graphemes("MMSS") && tl != br do
            acc + 1
          else
            acc
          end

        _ ->
          acc
      end
    end)
  end)

IO.inspect(part2)
