defmodule Day7 do
  def process(file_path) do
    file_path
    |> File.stream!()
    |> Stream.map(&Hand.parse/1)
    |> Enum.sort_by(&(&1.score))
    |> Stream.with_index()
    |> Stream.map(fn {hand, index} -> hand.bid * (index + 1) end)
    |> Enum.sum()
  end
end

defmodule Hand do
  defstruct [:cards, :bid, :score]

  def parse(text) do
    [cards_str, bid_str] =
      text
      |> String.trim()
      |> String.split()

    cards = String.codepoints(cards_str)
    bid = String.to_integer(bid_str)
    score = score(cards)

    %Hand{
      cards: cards,
      bid: bid,
      score: score
    }
  end

  @doc"""
  Having:
    The cards as: [card_1 card_2 card_3 card_4 card_5]
  Score =
      card_score(card_5) * (13^0)
    + card_score(card_4) * (13^1)
    + card_score(card_3) * (13^2)
    + card_score(card_2) * (13^3)
    + card_score(card_1) * (13^4)
    + type_score(type(cards)) * (13^5)
  """
  defp score([card_1, card_2, card_3, card_4, card_5] = cards) do
    [
      card_score(card_5) * :math.pow(13, 0),
      card_score(card_4) * :math.pow(13, 1),
      card_score(card_3) * :math.pow(13, 2),
      card_score(card_2) * :math.pow(13, 3),
      card_score(card_1) * :math.pow(13, 4),
      type_score(type(cards)) * :math.pow(13, 5)
    ]
    |> Enum.sum()
  end

  defp type(cards)
  defp type(["J","J","J","J","J"]), do: :five_of_kind
  defp type(cards) do
    jokers = Enum.count(cards, &(&1=="J"))
    filtered_cards = Enum.filter(cards,&(&1!="J") )

    [first|tail] =
      filtered_cards
      |> Enum.frequencies()
      |> Map.values()
      |> Enum.sort(:desc)

    adjusted_freqs = [first+jokers | tail]

    case adjusted_freqs do
      [5]             -> :five_of_kind
      [4, 1]          -> :four_of_kind
      [3, 2]          -> :full_house
      [3, 1, 1]       -> :three_of_kind
      [2, 2, 1]       -> :two_pair
      [2, 1, 1, 1]    -> :one_pair
      [1, 1, 1, 1, 1] -> :high_card
    end
  end

  defp type_score(type)
  defp type_score(:high_card), do: 0
  defp type_score(:one_pair), do: 1
  defp type_score(:two_pair), do: 2
  defp type_score(:three_of_kind), do: 3
  defp type_score(:full_house), do: 4
  defp type_score(:four_of_kind), do: 5
  defp type_score(:five_of_kind), do: 6

  defp card_score(card)
  defp card_score("J"), do: 0
  defp card_score("2"), do: 1
  defp card_score("3"), do: 2
  defp card_score("4"), do: 3
  defp card_score("5"), do: 4
  defp card_score("6"), do: 5
  defp card_score("7"), do: 6
  defp card_score("8"), do: 7
  defp card_score("9"), do: 8
  defp card_score("T"), do: 9
  defp card_score("Q"), do: 10
  defp card_score("K"), do: 11
  defp card_score("A"), do: 12
end

Day7.process("/Users/henriquebontempo/Dev/advent_of_code_2023/day7/input.txt")
|> IO.inspect()
