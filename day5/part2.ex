defmodule Day5 do
  def process(file_path) do
    [seed_chunck | dictionary_chunck_list] =
      File.read(file_path)
      |> elem(1)
      |> String.split("\n")
      |> Stream.chunk_by(&(&1 == ""))
      |> Enum.filter(&(&1 != [""]))

    dictionary_map =
      dictionary_chunck_list
      |> Stream.map(&Dictionary.parse_chunk/1)
      |> Map.new(fn dictionary -> {dictionary.source, dictionary} end)

    seed_ranges =
      parse_seed_chunk(seed_chunck)
      |> IO.inspect()

    Task.async_stream(
      seed_ranges,
      fn seed_range ->
        Stream.map(
          seed_range,
          &convert(dictionary_map, "seed", &1)
        )
        |> Enum.min()
      end,
      timeout: :infinity
    )
    |> Enum.min()
    |> elem(1)
  end

  defp convert(dictionary_map, type, value) do
    case Map.get(dictionary_map, type) do
      nil ->
        value

      dictionary ->
        target_type = dictionary.target
        target_value = Dictionary.translate(dictionary, value)
        convert(dictionary_map, target_type, target_value)
    end
  end

  defp parse_seed_chunk(seed_chunk) do
    [_ | seeds_str_list] =
      seed_chunk
      |> List.first()
      |> String.split()

    seeds_str_list
    |> Enum.map(fn seed_str ->
      seed_str
      |> String.to_integer()
    end)
    |> Stream.chunk_every(2)
    |> Enum.map(fn [start, length] -> start..(start + length - 1)//1 end)
  end
end

defmodule Dictionary do
  defstruct source: nil, target: nil, ranges: []

  def parse_chunk(text_chunk)

  def parse_chunk([description | translations]) do
    {source, target} = parse_description(description)
    ranges = parse_translations(translations)

    %Dictionary{
      source: source,
      target: target,
      ranges: ranges
    }
  end

  def translate(dictionary, value) do
    range =
      Enum.find(
        dictionary.ranges,
        fn {{start, finish}, _} -> value >= start and value <= finish end
      )

    case range do
      nil -> value
      {{start, _}, target} -> target + (value - start)
    end
  end

  defp parse_description(description) do
    description
    |> String.split()
    |> List.first()
    |> String.split("-to-")
    |> then(fn [s, t] -> {s, t} end)
  end

  defp parse_translations(translations) do
    Enum.map(translations, &parse_translation/1)
  end

  defp parse_translation(translation) do
    [target, source, length] =
      translation
      |> String.split()
      |> Enum.map(fn str ->
        str
        |> String.to_integer()
      end)

    {{source, source + length - 1}, target}
  end
end

Day5.process("/Users/henriquebontempo/Dev/advent_of_code_2023/day5/input.txt")
|> IO.inspect()
