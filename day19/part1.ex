defmodule Day19 do
  def process(file_path) do
    [workflow_collection_str, part_list_str] =
      file_path
      |> File.read!()
      |> String.split("\n\n")

    # IO.inspect(part_list_str)

    part_list =
      part_list_str
      |> PartList.parse()

    workflow_collection =
      workflow_collection_str
      |> WorkflowCollection.parse()

    workflow_map = Map.new(workflow_collection)
    # |> IO.inspect()


    {_, workflow} = List.first(workflow_collection)
    # |> IO.inspect()


    part_list
    |> Enum.map(&workflow.(&1, workflow_map))

    # part = List.first(part_list)
    # workflow = List.first(Map.values(workflow_collection))
    # workflow.(part, workflow_collection)
  end
end

defmodule Workflow do

  def parse(text) do
    text
    |> String.split(",")
    |> Enum.map(&parse_command/1)
    # |> IO.inspect()
    |> master_function()
  end

  defp master_function(functions)

  defp master_function([head_function | tail_functions]) do
    fn part, workflow_collection ->
      # IO.inspect(head_function.(part, workflow_collection))
      case head_function.(part, workflow_collection) do
        :accept -> :accept
        :reject -> :reject
        :next -> master_function(tail_functions).(part, workflow_collection)
      end
    end
  end

  defp parse_command(command)
  defp parse_command("A"), do: fn _, _ -> :accept end
  defp parse_command("R"), do: fn _, _ -> :reject end

  defp parse_command(command) do
    case String.contains?(command, ":") do
      false ->
        fn part, workflow_collection ->
          Map.get(workflow_collection, command).(part, workflow_collection)
        end

      true ->
        [condition, new_command] = String.split(command, ":")

        var =
          condition
          |> String.at(0)
          |> String.to_atom()

        operation =
          condition
          |> String.at(1)
          |> String.to_atom()

        value =
          condition
          |> String.slice(2..-1)
          |> String.to_integer()

        # IO.inspect({var, operation, value, new_command})

        fn part, workflow_collection ->
          part_value = Map.get(part, var)

          IO.inspect(
            %{
              part: part,
              var: var,
              part_value: part_value,
              operation: operation,
              value: value,
              apply: apply(Kernel, operation, [part_value, value]),
              new_command: new_command
            }
          )

          case apply(Kernel, operation, [part_value, value]) do
            true -> parse_command(new_command).(part, workflow_collection)
            false -> :next
          end
        end
    end
  end
end

defmodule WorkflowCollection do
  def parse(text) do
    text
    |> String.split("\n")
    |> Stream.map(&Regex.named_captures(~r/(?<name>^\w*){(?<workflow>.*)}/, &1))
    |> Stream.map(fn extract ->
      {
        Map.get(extract, "name"),
        Workflow.parse(Map.get(extract, "workflow"))
      }
    end)
    |> Enum.to_list()
  end
end

defmodule Part do
  defstruct [:x, :m, :a, :s]

  def parse(text) do
    text
    |> String.slice(1..-2)
    # |> IO.inspect()
    |> String.split(",")
    |> Stream.map(&String.split(&1, "="))
    |> Enum.reduce(
      Map.new(),
      fn [property_str, value_str], acc ->
        property = String.to_atom(property_str)
        value = String.to_integer(value_str)
        Map.put(acc, property, value)
      end
    )
    |> then(&struct(Part, &1))
  end
end

defmodule PartList do
  def parse(text) do
    text
    |> String.split("\n")
    # |> IO.inspect()
    |> Stream.map(&Part.parse/1)
    |> Enum.to_list()
  end
end

Day19.process("/Users/henriquebontempo/Dev/advent_of_code_2023/day19/input_small.txt")
|> IO.inspect()
