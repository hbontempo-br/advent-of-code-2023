defmodule Day13 do
  def process(file_path) do
    file_path
    |> File.read!()
    |> String.split("\n\n")
    |> Stream.map(&TerrainPatter.parse/1)
    |> Stream.map(&TerrainPatter.symmetry_point/1)
    |> sum()
  end

  def sum(symmetry_list) do
    symmetry_list
    |> Stream.map(
      fn symmetry ->
        case symmetry do
          {:vertical, x} -> x
          {:horizontal, x} -> 100 * x
        end
      end
    )
    |> Enum.sum()
  end
end

defmodule TerrainPatter do
  require Integer
  defstruct [:rows, :columns]

  def parse(text) do
    rows =
      text
      |> String.split("\n")

    columns =
      rows
      |> Stream.map(&String.codepoints/1)
      |> Stream.zip()
      |> Stream.map(&Tuple.to_list/1)
      |> Stream.map(&Enum.join/1)
      |> Enum.to_list()

    %TerrainPatter{
      rows: rows,
      columns: columns
    }
  end

  def symmetry_point(%TerrainPatter{rows: rows, columns: columns}) do
    case symmetry(columns) do
      nil -> {:horizontal, symmetry(rows)}
      x -> {:vertical, x}
    end
  end

  defp symmetry(list), do: symmetry(list, [], 0)
  defp symmetry(list1, list2, count)
  defp symmetry([head1 | tail1], [], 0), do: symmetry(tail1, [head1], 1)
  defp symmetry([], _list2, _count), do: nil
  defp symmetry(list1, list2, count) do
    s =
      Stream.zip(
        list1,
        list2
      )
      |> Enum.to_list()
      |> Enum.filter(&(elem(&1, 0) != elem(&1, 1)))

    case Enum.count(s) do
      1 ->
        {s1, s2} =
          s
          |> List.first()

        diff =
          Enum.zip(
            String.codepoints(s1),
            String.codepoints(s2)
          )
          |> Enum.filter(&(elem(&1, 0) != elem(&1, 1)))

        case Enum.count(diff) do
          1 -> count
          _ ->
            [head1|tail1] = list1
            symmetry(tail1, [head1|list2], count+1)
        end
      _ ->
        [head1|tail1] = list1
        symmetry(tail1, [head1|list2], count+1)
    end
  end
end

Day13.process("/Users/henriquebontempo/Dev/advent_of_code_2023/day13/input.txt")
|> IO.inspect()
