"""
Having:
| time = hold + drive # (or drive = time - hold)
| speed *  drive > distance
| speed = hold * 1
| with: hold between ]0, time[

This results in:
hold * (time - hold) > distance
-hold^2 + time * hold - distance > 0
(this is a simple quadratic equation: https://en.wikipedia.org/wiki/Quadratic_equation)
delta = time^2 - 4 * distance
delta_sqrt = sqrt(delta)
hold between ] time - delta_sqrt)/2,  time + delta_sqrt)/2 [

Response: intersection from  ] time - delta_sqrt)/2,  time + delta_sqrt)/2 [ and ]0, time[




"""

defmodule Day6 do
  def process(file_path) do
    File.read(file_path)
    |> elem(1)
    |> String.split("\n")
    |> Stream.map(fn line ->
      line
      |> String.split()
      |> Stream.drop(1)
      |> Enum.join()
      |> String.to_integer()
      |> then(&([&1]))
    end)
    |> Stream.zip() # Here:[{time, distance}]. Example: [{7, 9}, {15, 40}, {30, 200}]
    |> Stream.map(
      fn {time, distance} ->
        delta = time*time - 4 * distance
        delta_sqrt = :math.sqrt(delta)
        lower = (time - delta_sqrt)/2
        upper = (time + delta_sqrt)/2
        { {0, time}, { lower, upper }}
      end
    )
    # |> Enum.to_list()
    # |> IO.inspect()
    |> Stream.map(
      fn
        {{min1, max1}, {min2, max2}} when min1 > max2 or min2 > max1 -> {0, 0}
        {{min1, max1}, {min2, max2}} ->
          computed_min = trunc(max(min1, min2)) + 1
          computed_max = trunc(:math.ceil(min(max1, max2))) - 1
          if(
            computed_min<computed_max,
            do: {computed_min, computed_max},
            else: {0, 0}
            )
          end
    )
    # |> Enum.to_list()
    |> Stream.map( fn {f, c} -> c-f+1 end )
    |> Enum.product()
  end
end

Day6.process("/Users/henriquebontempo/Dev/advent_of_code_2023/day6/input.txt")
|> IO.inspect()
