defmodule Day8 do
  def process(file_path) do
    [instructions_str | network_str_list] =
      file_path
      |> File.read!()
      |> String.split("\n")
      |> Enum.filter(&(&1 != ""))

    instructions = Instructions.parse(instructions_str)
    network_map = NetworkMap.parse(network_str_list)
    walk(instructions, network_map)
  end

  def walk(instructions, network_map), do: walk(instructions, network_map, "AAA", 0)
  def walk(_, _, "ZZZ", step), do: step
  def walk(instructions, network_map, position, step) do
    options = Map.get(network_map, position)
    { walk_to , new_instructions } = Instructions.next(instructions)
    new_position = Map.get(options, walk_to)
    walk(new_instructions, network_map, new_position, step+1)
  end
end

defmodule Instructions do
  def parse(text) do
    text
    |> String.codepoints()
    |> :queue.from_list()
  end

  def next(instructions) do
    { {_, out}, temp_instructions } = :queue.out(instructions)
    new_queue = :queue.in(out, temp_instructions)
    {out, new_queue}
  end
end

defmodule NetworkMap do
  def parse(network_str_list)
  def parse(network_str_list), do: parse(network_str_list, Map.new())
  def parse([], network_map), do: network_map

  def parse([network_str | network_str_tail], network_map) do
    [key, val_str] =
      network_str
      |> String.split(" = ")

    [l, r] =
      val_str
      |> String.split(", ")
      |> Stream.map(&(String.trim_leading(&1, "(")))
      |> Stream.map(&(String.trim_trailing(&1, ")")))
      |> Enum.to_list()

    network_item =
      Map.new()
      |> Map.put("L", l)
      |> Map.put("R", r)

    new_map =
      network_map
      |> Map.put(key, network_item)

    parse(network_str_tail, new_map)
  end
end

Day8.process("/Users/henriquebontempo/Dev/advent_of_code_2023/day8/input.txt")
|> IO.inspect()
