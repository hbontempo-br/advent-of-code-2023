# Rewrite remembering that A product of two vectors is it's area.
# Walk the path at the same time the area is being calculated

defmodule Day18 do
  def process(file_path) do
    file_path
    |> parse_instruction()
    |> PathMap.generate()
    |> PathMap.print()
  end

  def parse_instruction(file_path) do
    file_path
    |> File.stream!()
    |> Stream.map(&Instruction.parse/1)
  end
end

defmodule Instruction do
  defstruct [:direction, :steps, :color]

  def parse(text) do
    [direction_str, steps_str, color_str] =
      text
      |> String.split()

    %Instruction{
      direction: direction(direction_str),
      steps: String.to_integer(steps_str),
      color: String.slice(color_str, 1..-2)
    }
  end

  defp direction(str)
  defp direction("U"), do: :up
  defp direction("D"), do: :down
  defp direction("L"), do: :left
  defp direction("R"), do: :right
end

defmodule PathMap do
  def generate(instructions) do
    walk(Enum.to_list(instructions), {0, 0}, Map.new())
  end

  def print(path_math) do
    {x1, x2, y1, y2} =
      path_math
      |> Map.keys()
      |> Enum.reduce(
        {0, 0, 0, 0},
        fn {x, y}, {min_x, max_x, min_y, max_y} ->
          {
            min(x, min_x),
            max(x, max_x),
            min(y, min_y),
            max(y, max_y)
          }
        end
      )

    y1..y2
    |> Enum.reduce(
      "",
      fn y, s1 ->
        x1..x2
        |> Enum.reduce(
          s1,
          fn x, s2 ->
            val = if Map.has_key?(path_math, {x, y}), do: "#", else: "."
            s2<>val
          end
        )
        |> then(&(&1<>"\n"))
      end
    )
    # |> IO.puts()
    |> then(&(File.write("/Users/henriquebontempo/Dev/advent_of_code_2023/day18/output.txt", &1)))

    path_math
  end

  defp walk(instuctions, position, map)
  defp walk([], _position, map), do: map

  defp walk([%Instruction{steps: 0} | tail] = instuctions, position, map),
    do: walk(tail, position, map)

  defp walk([instruction | tail], position, map) do
    %Instruction{
      steps: steps,
      direction: direction,
      color: color
    } = instruction

    new_instruction = %Instruction{
      steps: steps - 1,
      direction: direction,
      color: color
    }

    new_instructions = [new_instruction | tail]
    new_position = step(direction).(position)
    new_map = Map.put(map, new_position, color)

    walk(
      new_instructions,
      new_position,
      new_map
    )
  end

  def step(direction)
  def step(:right), do: fn {x, y} -> {x + 1, y} end
  def step(:left), do: fn {x, y} -> {x - 1, y} end
  def step(:up), do: fn {x, y} -> {x, y - 1} end
  def step(:down), do: fn {x, y} -> {x, y + 1} end
end

Day18.process("/Users/henriquebontempo/Dev/advent_of_code_2023/day18/input.txt")
# |> IO.inspect()
