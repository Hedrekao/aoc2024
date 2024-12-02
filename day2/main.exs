defmodule Day2 do
  defp valid?(list) do
    # check if the list in increasing order
    sorted = Enum.sort(list)

    if sorted != list and Enum.reverse(sorted) != list do
      false
    else
      # check if elements change by min 1 and max 3
      Enum.zip(sorted, Enum.drop(sorted, 1))
      |> Enum.map(fn {x, y} -> abs(y - x) end)
      |> Enum.all?(&(&1 <= 3 && &1 >= 1))
    end
  end

  def part1(file_name) do
    File.stream!(file_name)
    |> Stream.map(&String.trim/1)
    |> Enum.reduce([], fn x, acc ->
      [x |> String.split(" ") |> Enum.map(&String.to_integer/1) | acc]
    end)
    |> Enum.filter(&valid?/1)
    |> Enum.count()
  end

  def part2(file_name) do
    File.stream!(file_name)
    |> Stream.map(&String.trim/1)
    |> Enum.reduce([], fn x, acc ->
      [x |> String.split(" ") |> Enum.map(&String.to_integer/1) | acc]
    end)
    |> Enum.filter(fn list ->
      all_combinations = [list | Enum.map(0..(length(list) - 1), fn i -> List.delete_at(list,i) end)]
      Enum.any?(all_combinations, &valid?/1)
    end)
    |> Enum.count()
  end
end

file_name = "./day2/input.txt"
IO.inspect(Day2.part1(file_name))
IO.inspect(Day2.part2(file_name))
