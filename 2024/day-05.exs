#!/usr/bin/env elixir

# https://adventofcode.com/2024/day/5

add_to_mapset = fn map, key, value ->
  Map.get(map, key, MapSet.new())
  |> MapSet.put(value)
  |> (fn set -> Map.put(map, key, set) end).()
end

{rules, updates} =
  File.stream!("day-05.txt")
  |> Enum.map(&String.trim/1)
  |> Enum.reduce({%{}, []}, fn line, {rules, updates} ->
    cond do
      String.contains?(line, "|") ->
        [a, b] =
          line
          |> String.split("|")
          |> Enum.map(&String.to_integer/1)

        {add_to_mapset.(rules, a, b), updates}

      String.contains?(line, ",") ->
        update =
          line
          |> String.split(",")
          |> Enum.map(&String.to_integer/1)

        {rules, updates ++ [update]}

      true ->
        {rules, updates}
    end
  end)

middle_page_number = fn pages_to_print ->
  Enum.at(pages_to_print, trunc(Enum.count(pages_to_print) / 2))
end

correct_update_order = fn pages_to_print, rules ->
  {correct, _} =
    pages_to_print
    |> Enum.reduce({true, MapSet.new()}, fn page_to_print, {correct, printed_pages} ->
      {
        correct && MapSet.disjoint?(printed_pages, rules[page_to_print] || MapSet.new()),
        MapSet.put(printed_pages, page_to_print)
      }
    end)

  correct
end

part1 =
  updates
  |> Enum.reduce(0, fn pages_to_print, acc ->
    if correct_update_order.(pages_to_print, rules) do
      acc + middle_page_number.(pages_to_print)
    else
      acc
    end
  end)

IO.inspect(part1)

fix_the_order = fn pages_to_print, rules ->
  pages_to_print
  |> Enum.reduce([], fn page_to_print, result ->
    index =
      case rules[page_to_print] do
        nil ->
          Enum.count(result)

        page_rules ->
          page_rules
          |> Enum.reduce(Enum.count(result), fn before_page, idx ->
            min(idx, Enum.find_index(result, &(&1 == before_page)) || Enum.count(result))
          end)
      end

    List.insert_at(result, index, page_to_print)
  end)
end

part2 =
  updates
  |> Enum.reject(&correct_update_order.(&1, rules))
  |> Enum.map(&fix_the_order.(&1, rules))
  |> Enum.map(&middle_page_number.(&1))
  |> Enum.sum()

IO.inspect(part2)
