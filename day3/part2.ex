defmodule Day3 do
  def process(file_path) do
    initial_process =
      File.stream!(file_path)
      |> Stream.map(&String.trim/1)
      |> Stream.map(&parse_line/1)
      |> Stream.with_index()
      |> Enum.to_list()

    # |> IO.inspect()

    symbols =
      symbol_mapset(initial_process)

    # |> IO.inspect()

    numbers =
      numbers_list(initial_process)

    gears =
      gear_list(symbols, numbers)
      # |> IO.inspect()

    gears
    |> Stream.map(&gear_ratio/1)
    |> Enum.sum()
  end

  defp gear_ratio({_symbol, numbers}) do
    numbers
    |> Stream.map(fn {value, _, _, _} -> value end)
    |> Enum.product()
  end

  defp gear_list(symbols, numbers) do
    Enum.flat_map(
      symbols,
      fn symbol ->
        part_numbers =
          Enum.filter(
            numbers,
            fn {_, _, _, border} -> MapSet.member?(border, symbol) end
          )

        case Enum.count(part_numbers) do
          2 -> [{symbol, part_numbers}]
          _ -> []
        end
      end
    )
  end

  defp numbers_list(initial_process) do
    Enum.flat_map(
      initial_process,
      fn {{partial_number, _}, row} ->
        numbers_list(partial_number, row)
      end
    )
  end

  defp numbers_list(partial_number, row, numbers \\ [])
  defp numbers_list([], _, numbers), do: numbers

  defp numbers_list([{range, number_str} | partial_tail], row, numbers) do
    range_start..range_end = range

    border =
      Enum.concat(
        [{row, range_start - 1}, {row, range_end + 1}],
        Enum.flat_map(
          (range_start - 1)..(range_end + 1),
          fn column ->
            [
              # Upper boundry
              {row - 1, column},
              # Lower boundry
              {row + 1, column}
            ]
          end
        )
      )
      |> MapSet.new()

    {value, _} = Integer.parse(number_str)
    new_number = {value, range, row, border}
    numbers_list(partial_tail, row, [new_number | numbers])
  end

  defp symbol_mapset(initial_process) do
    Enum.reduce(
      initial_process,
      MapSet.new(),
      fn {{_, columns}, row}, acc ->
        MapSet.union(
          acc,
          Enum.reduce(
            columns,
            MapSet.new(),
            fn column, acc2 ->
              MapSet.put(acc2, {row, column})
            end
          )
        )
      end
    )
  end

  defp parse_line(text) do
    line_stream =
      text
      |> String.codepoints()
      |> Stream.with_index()

    symbols =
      line_stream
      |> Stream.filter(fn {codepoint, _} -> is_symbol?(codepoint) end)
      |> Stream.map(&elem(&1, 1))
      |> Enum.to_list()

    numbers =
      line_stream
      |> Stream.filter(fn {codepoint, _} -> is_numeric?(codepoint) end)
      |> Stream.map(&elem(&1, 1))
      |> Enum.to_list()
      |> numbers_array_to_ranges()
      |> Enum.map(fn number_range -> {number_range, String.slice(text, number_range)} end)

    {numbers, symbols}
  end

  defp numbers_array_to_ranges(numbers)
  defp numbers_array_to_ranges([]), do: []

  defp numbers_array_to_ranges([curr_position | tail]),
    do: numbers_array_to_ranges(tail, curr_position, curr_position, [])

  defp numbers_array_to_ranges(numbers, range_start, last_position, ranges)

  defp numbers_array_to_ranges([], range_start, last_position, ranges),
    do: [range_start..last_position | ranges]

  defp numbers_array_to_ranges([curr_position | tail], range_start, last_position, ranges) do
    # IO.inspect({[curr_position|tail], range_start, last_position, ranges})
    case last_position + 1 == curr_position do
      true ->
        numbers_array_to_ranges(tail, range_start, curr_position, ranges)

      false ->
        numbers_array_to_ranges(tail, curr_position, curr_position, [
          range_start..last_position | ranges
        ])
    end
  end

  defp is_numeric?(text) do
    case Integer.parse(text) do
      {_, _} -> true
      :error -> false
    end
  end

  defp is_symbol?(text) do
    text == "*"
  end
end

Day3.process("/Users/henriquebontempo/Dev/advent_of_code_2023/day3/input.txt")
|> IO.inspect()
