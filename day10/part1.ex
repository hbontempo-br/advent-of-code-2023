defmodule Day10 do
  def process(file_path) do
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
    |> furtherst_position()
  end

  defp furtherst_position(parameters)

  defp furtherst_position({map, not_visited_pos, {r, c}}) do
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

    furtherst_position(map, new_not_visited_pos, positions, 1)
  end

  defp furtherst_position(_, _, [pos1, pos2], distance) when pos1 == pos2, do: distance

  defp furtherst_position(map, not_visited_pos, positions, distance) do
    new_positions =
      positions
      |> Enum.flat_map(
        fn pos ->
          Map.get(map, pos)
          |> possible_positions(pos)
          |> Enum.filter(fn pos ->
            MapSet.member?(not_visited_pos, pos)
        end
        )
      end)

    new_not_visited_pos =
      new_positions
      |> Enum.reduce(
        not_visited_pos,
        fn pos, acc ->
          MapSet.delete(acc, pos)
        end
      )

    furtherst_position(map, new_not_visited_pos, new_positions, distance + 1)
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
