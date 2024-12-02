# Clear point of attention: avoid loops
# Ideas:
# - Keep a MapsSet off all positions and directions that light still haven't "ingressed" to (like a "allowed position")
# - Store visited nodes in a MapSet

defmodule Day16 do
  def process(file_path) do
    map =
      file_path
      |> read_map()

    allowed_set = allowed_actions(map)

    map
    |> possible_starts()
    |> Stream.map(
      fn action ->
        [action]
        |> transverse(map, allowed_set, MapSet.new())
        |> elem(1)
        |> MapSet.size()
      end
    )
    |> Enum.max
  end

  def possible_starts(map) do
    {max_row, max_col} = max(map)
    a = for row <- 0..max_row, do: { {row, 0},       :right }
    b = for row <- 0..max_row, do: { {row, max_col}, :left  }
    c = for col <- 0..max_col, do: { {0, col},       :down  }
    d = for col <- 0..max_col, do: { {max_row, col}, :up    }
    a ++ b ++ c ++ d
  end

  def max(map) do
    positions = Map.keys(map)
    max_row = positions |> Stream.map(fn {row, _} -> row end) |> Enum.max()
    max_col = positions |> Stream.map(fn {_, col} -> col end) |> Enum.max()
    {max_row, max_col}
  end

  def transverse(actions, map, allowed_set, traverssed_set) do
    actions
    |> Enum.reduce(
      {allowed_set, traverssed_set},
      fn curr_action, {acc_allowed_set, acc_traverssed_set} ->
        case MapSet.member?(acc_allowed_set, curr_action) do
          false ->
            {acc_allowed_set, acc_traverssed_set}

          true ->
            {curr_position, curr_direction} = curr_action
            new_allowed_set = MapSet.delete(acc_allowed_set, curr_action)
            new_traverssed_set = MapSet.put(acc_traverssed_set, curr_position)

            item = Map.get(map, curr_position)
            next_directions = next_directions(curr_direction, item)

            next_actions =
              next_directions
              |> Enum.map(&{next_position(curr_position, &1), &1})

            transverse(next_actions, map, new_allowed_set, new_traverssed_set)
        end
      end
    )
  end

  # def next_directions(curr_direction, piece)
  def next_directions(curr_direction, "."), do: [curr_direction]
  def next_directions(:right, "/"), do: [:up]
  def next_directions(:left, "/"), do: [:down]
  def next_directions(:up, "/"), do: [:right]
  def next_directions(:down, "/"), do: [:left]
  def next_directions(:right, "\\"), do: [:down]
  def next_directions(:left, "\\"), do: [:up]
  def next_directions(:up, "\\"), do: [:left]
  def next_directions(:down, "\\"), do: [:right]
  def next_directions(:right, "-"), do: [:right]
  def next_directions(:left, "-"), do: [:left]
  def next_directions(:up, "-"), do: [:right, :left]
  def next_directions(:down, "-"), do: [:right, :left]
  def next_directions(:right, "|"), do: [:up, :down]
  def next_directions(:left, "|"), do: [:up, :down]
  def next_directions(:up, "|"), do: [:up]
  def next_directions(:down, "|"), do: [:down]

  # def next_position({row_postion, col_position}, direction)
  def next_position({row_postion, col_position}, :right), do: {row_postion, col_position + 1}
  def next_position({row_postion, col_position}, :left), do: {row_postion, col_position - 1}
  def next_position({row_postion, col_position}, :up), do: {row_postion - 1, col_position}
  def next_position({row_postion, col_position}, :down), do: {row_postion + 1, col_position}

  def allowed_actions(map) do
    map
    |> Map.keys()
    |> Enum.flat_map(fn position ->
      [
        {position, :right},
        {position, :left},
        {position, :up},
        {position, :down}
      ]
    end)
    |> MapSet.new()
  end

  def read_map(file_path) do
    file_path
    |> File.stream!()
    |> Stream.map(&String.trim/1)
    |> Stream.with_index()
    |> Enum.reduce(
      Map.new(),
      fn {row_text, row_pos}, acc1 ->
        row_text
        |> String.codepoints()
        |> Stream.with_index()
        |> Enum.reduce(
          acc1,
          fn {char, col_pos}, acc2 -> Map.put(acc2, {row_pos, col_pos}, char) end
        )
      end
    )
  end
end

Day16.process("/Users/henriquebontempo/Dev/advent_of_code_2023/day16/input.txt")
|> IO.inspect()
