defmodule Day14 do
  def process(file_path) do
    file_path
    |> File.stream!()
    |> Stream.map(&String.trim/1)
    |> Stream.map(&String.codepoints/1)
    |> cycle_times(100000)
    |> compute_load()
  end

  def cycle_times(bla, 0), do: bla
  def cycle_times(bla, times) do
    cycle_times(
      cycle(bla),
      times - 1
    )
  end

  def cycle(bla) do
    bla
    |> tilt()
    |> rotate()
    |> tilt()
    |> rotate()
    |> tilt()
    |> rotate()
    |> tilt()
    |> rotate()
  end

  def compute_load(bla) do
    bla
    |> Stream.zip()
    |> Stream.map(&Tuple.to_list/1)
    |> Stream.map(fn row -> Enum.count(row, &(&1=="O")) end)
    |> Enum.reverse()
    |> Stream.with_index(1)
    |> Stream.map(&(elem(&1, 0) * elem(&1, 1)))
    |> Enum.sum()
  end

  def rotate(bla) do
    bla
    # |> Stream.zip()
    # |> Stream.map(&Tuple.to_list/1)
    |> Stream.map(&Enum.reverse/1)
  end

  def tilt(bla) do
    bla
    |> Stream.zip()
    |> Stream.map(&Tuple.to_list/1)
    |> Stream.map(fn col -> Enum.chunk_by(col, &(&1=="#")) end)
    |> Stream.map(
      fn chuncks ->
        chuncks
        |> Enum.map(
          fn chunck ->
            chunck
            |> Enum.sort(:desc)
          end
        )
        |> Enum.reduce([], fn c, acc -> acc ++ c end)
      end
    )
    # |> Stream.zip()
    # |> Stream.map(&Tuple.to_list/1)
  end
end



Day14.process("/Users/henriquebontempo/Dev/advent_of_code_2023/day14/input_small.txt")
|> IO.inspect()
