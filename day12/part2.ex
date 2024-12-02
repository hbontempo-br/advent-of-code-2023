defmodule Day12 do
  def process(file_path) do
    file_path
    |> Report.parse()
    |> Report.compute_possibilities()
  end
end

defmodule Report do
  def parse(file_path) do
    file_path
    |> File.stream!()
    |> Stream.map(&String.trim/1)
    |> Stream.map(&ReportRecord.parse/1)
  end

  def compute_possibilities(record_list) do
    record_list
    |> Task.async_stream(&ReportRecord.compute_possibilities/1, timeout: :infinity)
    |> Stream.map(fn {_, count} -> count end)
    |> Enum.sum()
  end
end

defmodule ReportRecord do
  defstruct [:analitic, :consolidated]

  def parse(str) do
    [analitic_str, consolidated_str] = String.split(str)

    real_analitic_str =
      1..5
      |> Stream.map(fn _ -> analitic_str end)
      |> Enum.join("?")

    real_consolidated_str =
      1..5
      |> Stream.map(fn _ -> consolidated_str end)
      |> Enum.join(",")

    %ReportRecord{
      analitic: parse_analitic_str(real_analitic_str),
      consolidated: parse_consolidated_str(real_consolidated_str)
    }
  end

  defp parse_analitic_str(str) do
    String.codepoints(str)
  end

  defp parse_consolidated_str(str) do
    str
    |> String.split(",")
    |> Enum.map(&String.to_integer/1)
  end

  def compute_possibilities(record) do
    record.analitic
    |> Enum.flat_map_reduce(
      [[]],
      fn status, acc ->
        new_acc =
          case status do
            "?" -> Enum.flat_map(acc, fn partial -> [["." | partial], ["#" | partial]] end)
            _ -> Enum.map(acc, fn partial -> [status | partial] end)
          end

        {new_acc, new_acc}
      end
    )
    |> elem(1)
    |> Task.async_stream(
      fn x ->
        # IO.inspect(record.consolidated)
        x
        |> Enum.reverse()
        |> consolidate()
        # |> IO.inspect()
        |> Kernel.==(record.consolidated)

        # |> IO.inspect()
      end,
      timeout: :infinity
    )
    |> Stream.map(fn {_, status} -> status end)
    # |> Enum.to_list()
    # |> IO.inspect()
    |> Enum.count(&(&1 == true))
  end

  defp consolidate(analitic), do: Enum.reverse(consolidate(analitic, 0, []))
  defp consolidate([], 0, partial_resp), do: partial_resp
  defp consolidate([], curr_count, partial_resp), do: [curr_count | partial_resp]
  defp consolidate(["." | tail], 0, partial_resp), do: consolidate(tail, 0, partial_resp)

  defp consolidate(["." | tail], curr_count, partial_resp),
    do: consolidate(tail, 0, [curr_count | partial_resp])

  defp consolidate(["#" | tail], curr_count, partial_resp),
    do: consolidate(tail, curr_count + 1, partial_resp)
end

Day12.process("/Users/henriquebontempo/Dev/advent_of_code_2023/day12/input.txt")
|> IO.inspect()
