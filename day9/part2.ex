

defmodule Day9 do
  def process(file_path) do
    file_path
    |> File.stream!()
    |> Stream.map(&String.trim/1)
    |> Stream.map(&String.split/1)
    |> Stream.map(fn number_strs ->
      number_strs
      |> Enum.map(&String.to_integer/1)
    end)
    |> Stream.map(&previous_val/1)
    # |> Enum.to_list()
    # |> IO.inspect()
    |> Enum.sum()
  end

  defp previous_val(numbers)

  defp previous_val(numbers) do
    # IO.inspect(numbers)
    case Enum.all?(numbers, &(&1 == 0)) do
      true ->
        0

      false ->
        d = diffs(numbers)
        n = previous_val(d)
        List.first(numbers) - n
    end
  end

  defp diffs(numbers)

  defp diffs([head | tail]) do
    diffs(tail, head, [])
  end

  defp diffs([], _, diffs), do: Enum.reverse(diffs)

  defp diffs([head | tail], last_val, diffs) do
    diffs(tail, head, [head - last_val | diffs])
  end
end

Day9.process("/Users/henriquebontempo/Dev/advent_of_code_2023/day9/input.txt")
|> IO.inspect()
