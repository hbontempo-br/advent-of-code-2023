defmodule Day11 do
  def process(file_path) do
    galaxies =
      file_path
      |> File.stream!()
      |> Stream.map(&String.trim/1)
      |> Stream.map(&String.codepoints/1)
      |> Stream.with_index()
      |> Enum.reduce(
        MapSet.new(),
        fn {row_values, row}, acc ->
          row_values
          |> Stream.with_index()
          |> Enum.reduce(
            acc,
            fn {val, col}, galaxies ->
              pos = {row, col}
              new_galaxies = if val == "#", do: MapSet.put(galaxies, pos), else: galaxies
            end
          )
        end
      )

    {populated_rows, populated_columns} =
      galaxies
      |> Enum.reduce(
        {MapSet.new(), MapSet.new()},
        fn {row, col}, {map_row, map_col} ->
          new_map_row = MapSet.put(map_row, row)
          new_map_col = MapSet.put(map_col, col)
          {new_map_row, new_map_col}
        end
      )

    galaxy_pairs =
      for(x <- galaxies, y <- galaxies, x != y, do: {x, y})
      |> Enum.uniq_by(fn {x, y} -> MapSet.new([x, y]) end)

    galaxy_pairs
    |> Stream.map(fn {{row1, col1}, {row2, col2}} ->
      row_distance =
        row1..row2
        |> Stream.map(fn row ->
          case MapSet.member?(populated_rows, row) do
            true -> 1
            false -> 2
          end
        end)
        |> Enum.sum()
        |> then(&(&1 - 1))

      col_distance =
        col1..col2
        |> Stream.map(fn col ->
          case MapSet.member?(populated_columns, col) do
            true -> 1
            false -> 2
          end
        end)
        |> Enum.sum()
        |> then(&(&1 - 1))

      row_distance + col_distance
    end)
    |> Enum.sum()
  end
end

Day11.process("/Users/henriquebontempo/Dev/advent_of_code_2023/day11/input.txt")
|> IO.inspect()
