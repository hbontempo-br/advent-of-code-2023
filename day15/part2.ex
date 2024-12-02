# (x * 17) // 256
# 17 is a prime number
# 256 = 2^8 = 8bit
# x = x1 + x2 where 0 <= x1 <= 255 and 32 < x2 126


defmodule Day15 do
  def process(file_path) do
    file_path
    |> File.read!()
    |> String.split(",")
    |> Stream.map(&parse_instruction/1)
    # |> Enum.to_list()
    # |> IO.inspect()
    |> perform_instructions()
    # |> IO.inspect()
    |> focus_power
  end

  def parse_instruction(instruction_text) do
    {label, action} = case String.last(instruction_text) do
      "-" -> {String.slice(instruction_text, 0..-2), :-}
      s -> {String.slice(instruction_text, 0..-3), {:=, String.to_integer(s)}}
    end
    {label, hash(label), action}
  end

  def perform_instructions(instructions) do
    Enum.reduce(
      instructions,
      Map.new(),
      fn instruction, box_map -> perform_instruction(instruction, box_map) end
    )
  end

  def focus_power(box_map) do
    box_map
    |> Map.to_list()
    # |> IO.inspect()
    |> Enum.flat_map(
      fn {box, item_list} ->
        box_val = box + 1

        item_list
        |> Enum.reverse()
        |> Stream.with_index(1)
        |> Enum.flat_map(
          fn { {_, focus}, slot } ->
            [[box_val, slot, focus]]
          end
        )
      end
    )
    # |> IO.inspect()
    |> Enum.map(&Enum.product/1)
    # |> IO.inspect()
    |> Enum.sum()
  end

  def hash(text) do
    text
    |> String.to_charlist()
    |> Enum.reduce(0, &(rem((&1 + &2) * 17, 256)))
  end

  def perform_instruction({label, box, :-}, box_map), do: delete(label, box, box_map)
  def perform_instruction({label, box, {:=, focus}}, box_map), do: put(label, box, focus, box_map)

  def put(label, box, focus, box_map) do
    Map.update(
      box_map,
      box,
      [{label, focus}],
      fn curr_list ->
        in_curr_list = Enum.any?(
          curr_list,
          fn {curr_label, _curr_focus} -> label == curr_label end
        )

        case in_curr_list do
          false -> [{label, focus} | curr_list]
          true ->
            Enum.map(
              curr_list,
              fn {curr_label, curr_focus} ->
                case label == curr_label do
                  true -> { label,  focus}
                  false -> { curr_label,  curr_focus}
                end
              end
            )
        end

      end
    )
  end

  def delete(label, box, box_map) do
    Map.update(
      box_map,
      box,
      [],
      fn curr_list ->
        Enum.flat_map(
          curr_list,
          fn { curr_label, _focus } = lens ->
            if curr_label == label, do: [], else: [lens]
          end
        )
      end
    )
  end

end



Day15.process("/Users/henriquebontempo/Dev/advent_of_code_2023/day15/input.txt")
|> IO.inspect()
