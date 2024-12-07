defmodule Day7 do

  def solve_1([hd | tl], target) do
   backtrack_1(tl, target, hd)
 end

 defp backtrack_1([], target, result) do
   result == target
 end

 defp backtrack_1([hd | tl], target, result) do
   backtrack_1(tl, target, result + hd) ||
   backtrack_1(tl, target, result * hd)
 end

  def solve_2([hd | tl], target) do
   backtrack_2(tl, target, hd)
 end

 defp backtrack_2([], target, result) do
   result == target
 end

 defp backtrack_2([hd | tl], target, result) do
   backtrack_2(tl, target, result + hd) ||
   backtrack_2(tl, target, result * hd) ||
   backtrack_2(tl, target, Integer.to_string(result) <> Integer.to_string(hd) |> String.to_integer())
 end

  def part1(file_name) do
    File.stream!(file_name)
    |> Stream.map(&String.trim/1)
    |> Enum.reduce(0, fn line, acc ->
      [target, other_nums] = String.split(line, ": ")
      target = target |> String.to_integer()
      other_nums = other_nums |> String.split(" ") |> Enum.map(&String.to_integer/1)

      case solve_1(other_nums, target) do
        true -> acc + target
        false -> acc
      end

    end)
  end

  def part2(file_name) do
    File.stream!(file_name)
    |> Stream.map(&String.trim/1)
    |> Enum.reduce(0, fn line, acc ->
      [target, other_nums] = String.split(line, ": ")
      target = target |> String.to_integer()
      other_nums = other_nums |> String.split(" ") |> Enum.map(&String.to_integer/1)

      case solve_2(other_nums, target) do
        true -> acc + target
        false -> acc
      end

    end)
  end

end

file_name = "./day7/input.txt"
IO.inspect(Day7.part1(file_name))
IO.inspect(Day7.part2(file_name))
