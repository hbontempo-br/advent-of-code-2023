defmodule Day4 do
  def process(file_path) do
    card_map =
      file_path
      |> File.stream!()
      |> Stream.map(&Card.parse_line/1)
      |> Enum.to_list()
      |> CardMap.new()
      |> CardMap.compute_copies()
      |> CardMap.total()
  end
end

defmodule CardMap do
  def new(cards), do: Map.new(cards, fn card -> {card.id, card} end)

  def total(card_map) do
    card_map
    |> Map.values()
    |> Stream.map(&Card.count/1)
    |> Enum.sum()
  end

  def compute_copies(card_map) do
    ids = Map.keys(card_map) |> Enum.sort()

    ids
    |> Enum.reduce(
      card_map,
      fn id, updated_card_map ->
        card = Map.get(updated_card_map, id)
        card_value = Card.value(card)
        qnt = Card.count(card)

        # IO.inspect({card, card_value, qnt})

        new_card_map = (id + 1)..(id + card_value)//1
        |> Range.to_list()
        |> Enum.reduce(
          updated_card_map,
          fn id, cm -> CardMap.make_copies(cm, id, qnt) end
        )
        # |> IO.inspect()

        new_card_map
      end
    )
  end

  def make_copies(card_map, id, qnt) do
    case Map.has_key?(card_map, id) do
      false ->
        card_map

      true ->
        Map.update(
          card_map,
          id,
          nil,
          fn card -> Card.add_copies(card, qnt) end
        )
        # |> IO.inspect()
    end
  end
end

defmodule Card do
  defstruct id: nil, winning_numbers: MapSet.new(), your_numbers: [], copies: 0

  def parse_line(text) do
    [part_1, part_2] =
      text
      |> String.trim()
      |> String.split(":")

    # |> IO.inspect()

    id =
      part_1
      |> String.trim()
      |> String.split()
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
      |> Enum.map(fn number_str ->
        number_str
        |> Integer.parse()
        |> elem(0)
      end)
      |> MapSet.new()

    # |> IO.inspect()

    your_numbers =
      part_2_2
      |> String.trim()
      |> String.split()
      |> Enum.map(fn number_str ->
        number_str
        |> Integer.parse()
        |> elem(0)
      end)

    # |> IO.inspect()

    %Card{
      id: id,
      winning_numbers: winning_numbers,
      your_numbers: your_numbers
    }
  end

  def add_copies(card, qnt), do: %Card{card | copies: card.copies + qnt}

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
  end

  def count(card), do: card.copies + 1
end

Day4.process("/Users/henriquebontempo/Dev/advent_of_code_2023/day4/input.txt")
|> IO.inspect()
