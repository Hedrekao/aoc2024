defmodule Day1 do
  def part1(file_name) do
    File.stream!(file_name)
    |> Stream.map(&String.trim/1)
    |> Enum.reduce({[], []}, fn x, {first_list, last_list} ->
      [first_item, last_item] = x |> String.split("   ") |> Enum.map(&String.to_integer/1)
      {[first_item | first_list], [last_item | last_list]}
    end)
    |> then(fn {first_list, last_list} ->
      Enum.zip(Enum.sort(first_list), Enum.sort(last_list))
    end)
    |> Enum.map(fn {a, b} -> abs(a - b) end)
    |> Enum.sum()
  end

  def part2(file_name) do
    File.stream!(file_name)
    |> Stream.map(&String.trim/1)
    |> Enum.reduce({%{}, []}, fn x, {map, list} ->
      [first_item, last_item] = x |> String.split("   ") |> Enum.map(&String.to_integer/1)

      {Map.update(map, last_item, 1, &(&1 + 1)), [first_item | list]}
    end)
    |> then(fn {map, list} ->
      Enum.reduce(list, 0, fn x, acc ->
        case Map.get(map, x) do
          0 -> acc
          nil -> acc
          val -> acc + x * val
        end
      end)
    end)
  end
end

file_name = "./day1/input.txt"
IO.inspect(Day1.part1(file_name))
IO.inspect(Day1.part2(file_name))
