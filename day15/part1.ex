# (x * 17) // 256
# 17 is a prime number
# 256 = 2^8 = 8bit
# x = x1 + x2 where 0 <= x1 <= 255 and 32 < x2 126


defmodule Day15 do
  def process(file_path) do
    file_path
    |> File.read!()
    |> String.split(",")
    |> Stream.map(&hash/1)
    |> Enum.sum()
  end

  def hash(text) do
    text
    |> String.to_charlist()
    |> Enum.reduce(0, &(rem((&1 + &2) * 17, 256)))
  end
end



Day15.process("/Users/henriquebontempo/Dev/advent_of_code_2023/day15/input.txt")
|> IO.inspect()
