defmodule Day1 do
  def process(file_path) do
    File.stream!(file_path)
      |> Stream.map(&String.trim/1)
      |> Stream.map(&extract_value/1)
      |> Stream.map(&number/1)
      |> Enum.sum()
    end

  def extract_value(text) do
    codepoints = String.codepoints(text)
    {f, tail_codepoints} = first_digit(codepoints)
    l = last_digit(tail_codepoints, f)
    {f, l}
  end

  def first_digit([head|tail]) do
    case Integer.parse(head) do
      :error -> first_digit(tail)
      {digit, _} -> { digit, tail }
    end
  end

  def last_digit([], current_last_digit), do: current_last_digit
  def last_digit([head|tail], current_last_digit) do
    case Integer.parse(head) do
      :error -> last_digit(tail, current_last_digit)
      {digit, _} -> last_digit(tail, digit)
    end
  end

  def number({f, l}), do: f*10 + l

end

Day1.process("/Users/henriquebontempo/Dev/advent_of_code_2023/day1/input.txt")
  |> IO.puts()
