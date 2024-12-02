# Rewrite remembering that A product of two vectors is it's area.
# Walk the path at the same time the area is being calculated

defmodule Day10 do
  def process(file_path) do
    file_path
    |> parse_file()
    |> path()
    |> IO.inspect()
    |> inside()
    |> IO.inspect()
    |> Enum.count()
  end

  defp inside(path) do
    path_list = MapSet.to_list(path)

    path_rows = Enum.map(path_list, fn {row, _} -> row end)
    path_cols = Enum.map(path_list, fn {_, col} -> col end)

    min_row = Enum.min(path_rows)
    max_row = Enum.max(path_rows)

    min_col = Enum.min(path_cols)
    max_col = Enum.max(path_cols)

    inside1 =
      min_row..max_row
      |> Enum.reduce(
        MapSet.new(),
        fn row, acc ->
          min_col..max_col
          |> Enum.reduce(
            {acc, false},
            fn col, {new_acc, is_inside} ->
              pos = {row, col}
              border = MapSet.member?(path, {row, col})

              new_is_inside =
                case {is_inside, border} do
                  {false, false} -> false
                  {true, false} -> true
                  {true, true} -> false
                  {false, true} -> true
                end

              case new_is_inside do
                true -> {MapSet.put(new_acc, pos), new_is_inside}
                false -> {new_acc, new_is_inside}
              end
            end
          )
          |> elem(0)
        end
      )

    inside2 =
      min_col..max_col
      |> Enum.reduce(
        MapSet.new(),
        fn col, acc ->
          min_row..max_row
          |> Enum.reduce(
            {acc, false},
            fn row, {new_acc, is_inside} ->
              pos = {row, col}
              border = MapSet.member?(path, {row, col})

              new_is_inside =
                case {is_inside, border} do
                  {false, false} -> false
                  {true, false} -> true
                  {true, true} -> false
                  {false, true} -> true
                end

              case new_is_inside do
                true -> {MapSet.put(new_acc, pos), new_is_inside}
                false -> {new_acc, new_is_inside}
              end
            end
          )
          |> elem(0)
        end
      )

    inside3 =
      min_col..max_col
      |> Enum.reduce(
        MapSet.new(),
        fn col, acc ->
          max_row..min_row
          |> Enum.reduce(
            {acc, false},
            fn row, {new_acc, is_inside} ->
              pos = {row, col}
              border = MapSet.member?(path, {row, col})

              new_is_inside =
                case {is_inside, border} do
                  {false, false} -> false
                  {true, false} -> true
                  {true, true} -> false
                  {false, true} -> true
                end

              case new_is_inside do
                true -> {MapSet.put(new_acc, pos), new_is_inside}
                false -> {new_acc, new_is_inside}
              end
            end
          )
          |> elem(0)
        end
      )

    inside4 =
      min_row..max_row
      |> Enum.reduce(
        MapSet.new(),
        fn row, acc ->
          max_col..min_col
          |> Enum.reduce(
            {acc, false},
            fn col, {new_acc, is_inside} ->
              pos = {row, col}
              border = MapSet.member?(path, {row, col})

              new_is_inside =
                case {is_inside, border} do
                  {false, false} -> false
                  {true, false} -> true
                  {true, true} -> false
                  {false, true} -> true
                end

              case new_is_inside do
                true -> {MapSet.put(new_acc, pos), new_is_inside}
                false -> {new_acc, new_is_inside}
              end
            end
          )
          |> elem(0)
        end
      )

    inside =
      inside1
      |> MapSet.to_list()
      |> Stream.filter(&MapSet.member?(inside2, &1))
      |> Stream.filter(&MapSet.member?(inside3, &1))
      |> Stream.filter(&MapSet.member?(inside4, &1))
      |> MapSet.new()

    path_list
    |> Enum.reduce(
      inside,
      fn pos, acc -> MapSet.delete(acc, pos) end
    )
  end

  defp parse_file(file_path) do
    file_path
    |> File.stream!()
    |> Stream.map(&String.trim/1)
    |> Stream.map(&String.codepoints/1)
    |> Stream.with_index()
    |> Enum.reduce(
      {Map.new(), MapSet.new(), nil},
      fn {row_values, row}, acc ->
        row_values
        |> Stream.with_index()
        |> Enum.reduce(
          acc,
          fn {val, col}, {map, set, start} ->
            pos = {row, col}
            new_map = Map.put(map, pos, val)

            case val == "S" do
              true -> {new_map, set, pos}
              false -> {new_map, MapSet.put(set, pos), start}
            end
          end
        )
      end
    )
  end

  defp path(parameters)

  defp path({map, not_visited_pos, {r, c} = pos}) do
    positions =
      [
        {{r - 1, c}, ["|", "7", "F"]},
        {{r + 1, c}, ["|", "J", "L"]},
        {{r, c - 1}, ["-", "L", "F"]},
        {{r, c + 1}, ["-", "7", "J"]}
      ]
      |> Enum.flat_map(fn {pos, possibilities} ->
        val = Map.get(map, pos)

        case Enum.member?(possibilities, val) do
          true -> [pos]
          false -> []
        end
      end)

    new_not_visited_pos =
      positions
      |> Enum.reduce(
        not_visited_pos,
        fn pos, acc -> MapSet.delete(acc, pos) end
      )

    visited_pos = MapSet.new([pos | positions])

    path(map, new_not_visited_pos, visited_pos, positions, 1)
  end

  defp path(_, _, visited_pos, [pos1, pos2], distance) when pos1 == pos2, do: visited_pos

  defp path(map, not_visited_pos, visited_pos, positions, distance) do
    new_positions =
      positions
      |> Enum.flat_map(fn pos ->
        Map.get(map, pos)
        |> possible_positions(pos)
        |> Enum.filter(fn pos ->
          MapSet.member?(not_visited_pos, pos)
        end)
      end)

    new_not_visited_pos =
      new_positions
      |> Enum.reduce(
        not_visited_pos,
        fn pos, acc ->
          MapSet.delete(acc, pos)
        end
      )

    new_visited_pos =
      new_positions
      |> Enum.reduce(
        visited_pos,
        fn p, acc -> MapSet.put(acc, p) end
      )

    path(map, new_not_visited_pos, new_visited_pos, new_positions, distance + 1)
  end

  def look_at(str)
  def look_at("|"), do: [{-1, 0}, {1, 0}]
  def look_at("-"), do: [{0, -1}, {0, 1}]
  def look_at("7"), do: [{0, -1}, {1, 0}]
  def look_at("F"), do: [{0, 1}, {1, 0}]
  def look_at("J"), do: [{0, -1}, {-1, 0}]
  def look_at("L"), do: [{0, 1}, {-1, 0}]
  def look_at(_), do: []

  def possible_positions(str, {row, col}) do
    str
    |> look_at()
    |> Enum.map(fn {delta_row, delta_col} ->
      {row + delta_row, col + delta_col}
    end)
  end
end

Day10.process("/Users/henriquebontempo/Dev/advent_of_code_2023/day10/input.txt")
|> IO.inspect()
