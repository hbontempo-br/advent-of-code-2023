defmodule Day1 do
  def process(file_path) do
    File.stream!(file_path)
    |> Stream.map(&String.trim/1)
    |> Stream.map(&extract_value/1)
    |> Stream.map(&number/1)
    |> Enum.sum()
  end

  defp extract_value(text) do
    digits = extract_digits(text)
    f = List.first(digits)
    l = List.last(digits)
    {f, l}
  end

  defp extract_digits(text, digits \\ [])
  defp extract_digits("", digits), do: Enum.reverse(digits)
  defp extract_digits(text, digits) do
    {first_character, remainder_string} = String.split_at(text, 1)
    case Integer.parse(first_character) do
      {new_digit, _} -> extract_digits(remainder_string, [new_digit|digits])
      :error ->
        cond do
          String.starts_with?(text, "one")   -> extract_digits(remainder_string, [1|digits])
          String.starts_with?(text, "two")   -> extract_digits(remainder_string, [2|digits])
          String.starts_with?(text, "three") -> extract_digits(remainder_string, [3|digits])
          String.starts_with?(text, "four")  -> extract_digits(remainder_string, [4|digits])
          String.starts_with?(text, "five")  -> extract_digits(remainder_string, [5|digits])
          String.starts_with?(text, "six")   -> extract_digits(remainder_string, [6|digits])
          String.starts_with?(text, "seven") -> extract_digits(remainder_string, [7|digits])
          String.starts_with?(text, "eight") -> extract_digits(remainder_string, [8|digits])
          String.starts_with?(text, "nine")  -> extract_digits(remainder_string, [9|digits])
          true                               -> extract_digits(remainder_string, digits)
        end
    end
  end

  defp number({f, l}), do: f * 10 + l
end

Day1.process("/Users/henriquebontempo/Dev/advent_of_code_2023/day1/input.txt")
|> IO.puts()
