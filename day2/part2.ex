defmodule Day2 do
  def process(file_path) do
    File.stream!(file_path)
    |> Stream.map(&Game.parse_line/1)
    |> Stream.map(&power/1)
    # |> Enum.to_list()
    # |> IO.inspect()
    |> Enum.sum()
  end

  def power(game) do
    min =Enum.reduce(
        game.cube_sets,
        %{"red" => 0, "green" => 0, "blue" => 0},
        fn cube_set, acc ->
          red = Map.get(cube_set, "red", 0)
          green = Map.get(cube_set, "green", 0)
          blue = Map.get(cube_set, "blue", 0)

          acc
          |> Map.put("red",   max(Map.get(acc, "red"),   red))
          |> Map.put("green", max(Map.get(acc, "green"), green))
          |> Map.put("blue",  max(Map.get(acc, "blue"),  blue))
        end
      )
      # |> IO.inspect()
    Map.get(min, "red") * Map.get(min, "green") * Map.get(min, "blue")
  end
end

defmodule Game do
  defstruct number: nil, cube_sets: []

  def parse_line(line) do
    [number_str, cube_sets_str] =
      line
      |> String.trim()
      |> String.split(":")

    number = parse_number(number_str)
    cube_sets = parse_cube_sets(cube_sets_str)

    %Game{number: number, cube_sets: cube_sets}
  end

  defp parse_number(number_str) do
    number_str
    |> String.trim()
    |> String.split()
    |> Enum.at(1)
    |> Integer.parse()
    |> elem(0)
  end

  defp parse_cube_sets(cube_sets_str) do
    cube_sets_str
    |> String.trim()
    |> String.split(";")
    |> Stream.map(&parse_cube_set/1)
    |> Enum.to_list()
  end

  defp parse_cube_set(cube_set_str) do
    cube_set_str
    |> String.trim()
    |> String.split(",")
    |> Stream.map(&String.trim/1)
    |> Stream.map(&String.split/1)
    |> Enum.reduce(
      Map.new(),
      fn [count_str, color], acc ->
        {count, _} = Integer.parse(count_str)
        Map.put(acc, color, count)
      end
    )
  end
end

Day2.process("/Users/henriquebontempo/Dev/advent_of_code_2023/day2/input.txt")
|> IO.inspect()
