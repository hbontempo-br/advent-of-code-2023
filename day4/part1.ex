defmodule Day4 do
  def process(file_path) do
    file_path
    |> File.stream!()
    |> Stream.map(&Card.parse_line/1)
    |> Stream.map(&Card.value/1)
    |> Enum.sum()
  end
end

defmodule Card do
  defstruct id: nil, winning_numbers: MapSet.new(), your_numbers: []

  def parse_line(text) do
    [part_1, part_2] =
      text
      |> String.trim()
      |> String.split(":")
      |> IO.inspect()

    id =
      part_1
      |> String.trim()
      |> String.split()
      |> IO.inspect()
      |> Enum.at(1)
      |> Integer.parse()
      |> elem(0)
      # |> IO.inspect()

    [part_2_1, part_2_2] =
      part_2
      |> String.trim()
      |> String.split("|")
      # |> IO.inspect()

    winning_numbers =
      part_2_1
      |> String.trim()
      |> String.split()
      |> Enum.map(
        fn number_str ->
          number_str
          |> Integer.parse()
          |> elem(0)
        end
      )
      |> MapSet.new()
      # |> IO.inspect()

    your_numbers =
      part_2_2
      |> String.trim()
      |> String.split()
      |> Enum.map(
        fn number_str ->
          number_str
          |> Integer.parse()
          |> elem(0)
        end
      )
      # |> IO.inspect()

    %Card{
      id: id,
      winning_numbers: winning_numbers,
      your_numbers: your_numbers
    }
  end

  def your_winning_numbers(card) do
    Enum.filter(
      card.your_numbers,
      fn number ->
        MapSet.member?(card.winning_numbers, number)
      end
    )
    # |> IO.inspect()
  end

  def value(card) do
    count =
      card
      |> your_winning_numbers()
      |> Enum.count()

    case count do
      0 -> 0
      _ -> Integer.pow(2, count - 1)
    end
    # |> IO.inspect()
  end
end

Day4.process("/Users/henriquebontempo/Dev/advent_of_code_2023/day4/input.txt")
|> IO.inspect()
