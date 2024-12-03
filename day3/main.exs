defmodule Day3 do
  defp parse_line(line, part2) do
    parse_line_rec(line, "", [], [], true, part2)
  end

  # base case
  defp parse_line_rec([], _, _, acc, _, _) do
    acc
  end

  defp parse_line_rec([h | t], str, current_mull, acc, enabled, part2) do
    case length(current_mull) do
      0 ->
        parse_text([h | t], str, acc, enabled, part2)

      1 ->
        parse_number([h | t], str, current_mull, acc, enabled, part2)

      3 ->
        parse_number([h | t], str, current_mull, acc, enabled, part2)

      5 when (enabled and part2) or not part2 ->
        parse_line_rec([h | t], "", [], [current_mull | acc], enabled, part2)

      _ ->
        parse_line_rec(t, "", [], acc, enabled, part2)
    end
  end

  defp parse_text([h | t], str, acc, enabled, part2) do
    case {str, h} do
      {"", "m"} -> parse_line_rec(t, "m", [], acc, enabled, part2)
      {"m", "u"} -> parse_line_rec(t, "mu", [], acc, enabled, part2)
      {"mu", "l"} -> parse_line_rec(t, "mul", [], acc, enabled, part2)
      {"mul", "("} -> parse_line_rec(t, "", ["mul(" | []], acc, enabled, part2)
      {"", "d"} -> parse_line_rec(t, "d", [], acc, enabled, part2)
      {"d", "o"} -> parse_line_rec(t, "do", [], acc, enabled, part2)
      {"do", "("} -> parse_line_rec(t, "do(", [], acc, enabled, part2)
      {"do(", ")"} -> parse_line_rec(t, "", [], acc, true, part2)
      {"do", "n"} -> parse_line_rec(t, "don", [], acc, enabled, part2)
      {"don", "'"} -> parse_line_rec(t, "don'", [], acc, enabled, part2)
      {"don'", "t"} -> parse_line_rec(t, "don't", [], acc, enabled, part2)
      {"don't", "("} -> parse_line_rec(t, "don't(", [], acc, enabled, part2)
      {"don't(", ")"} -> parse_line_rec(t, "", [], acc, false, part2)
      {_, _} -> parse_line_rec(t, "", [], acc, enabled, part2)
    end
  end

  defp parse_number([h | t], str, current_mull, acc, enabled, part2) do
    case h do
      number when number in ["0", "1", "2", "3", "4", "5", "6", "7", "8", "9"] ->
        parse_line_rec(t, str <> h, current_mull, acc, enabled, part2)

      _ when str != "" and h == "," and length(current_mull) == 1 ->
        parse_line_rec(t, "", [",", str | current_mull], acc, enabled, part2)

      _ when str != "" and h == ")" and length(current_mull) == 3 ->
        parse_line_rec(t, "", [")", str | current_mull], acc, enabled, part2)

      _ ->
        parse_line_rec(t, "", [], acc, enabled, part2)
    end
  end

  def part1(file_name) do
    File.stream!(file_name)
    |> Stream.map(&String.trim/1)
    |> Stream.map(&String.graphemes/1)
    |> Enum.map(&parse_line(&1, false))
    |> Enum.concat()
    |> Enum.reduce(0, fn list, acc ->
      first_number = Enum.at(list, 1) |> String.to_integer()
      second_number = Enum.at(list, 3) |> String.to_integer()

      acc + first_number * second_number
    end)
  end

  def part2(file_name) do
    File.stream!(file_name)
    |> Stream.map(&String.trim/1)
    |> Stream.map(&String.graphemes/1)
    |> Enum.map(&parse_line(&1, true))
    |> Enum.concat()
    |> Enum.reduce(0, fn list, acc ->
      first_number = Enum.at(list, 1) |> String.to_integer()
      second_number = Enum.at(list, 3) |> String.to_integer()

      acc + first_number * second_number
    end)
  end
end

file_name = "./day3/input.txt"
IO.inspect(Day3.part1(file_name))
IO.inspect(Day3.part2(file_name))
