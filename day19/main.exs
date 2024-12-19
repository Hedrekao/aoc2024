defmodule Day19 do
  defp parse_input([line | rest], is_pattern, {patterns, towels} = acc) do
    case line do
      "" ->
        parse_input(rest, !is_pattern, acc)

      _ ->
        case is_pattern do
          true ->
            new_patterns = String.split(line, ", ") |> MapSet.new()
            parse_input(rest, is_pattern, {new_patterns, towels})

          false ->
            parse_input(rest, is_pattern, {patterns, [line | towels]})
        end
    end
  end

  defp parse_input([], _, acc) do
    acc
  end

  defp check_towel([_ | _] = towel, patterns) do
    1..length(towel)
    |> Enum.any?(fn len ->
      str = towel |> Enum.take(len) |> Enum.join()

      case MapSet.member?(patterns, str) do
        true ->
          remaining_str = Enum.drop(towel, len)
          check_towel(remaining_str, patterns)

        false ->
          false
      end
    end)
  end

  defp check_towel([], _) do
    true
  end

  def part1(file_name) do
    {patterns, towels} =
      File.stream!(file_name)
      |> Enum.map(&String.trim/1)
      |> parse_input(true, {MapSet.new(), []})

    towels
    |> Enum.reverse()
    |> Enum.reduce(0, fn towel, acc ->
      # check if towel can be constructed from patterns

      case check_towel(String.graphemes(towel), patterns) do
        true ->
          acc + 1

        false ->
          acc
      end
    end)
  end

  defp find_all_options([_ | _] = towel, patterns, cache) do
    towel_key = Enum.join(towel)

    case Map.get(cache, towel_key) do
      nil ->
        {result, new_cache} = calculate_options(towel, patterns, cache)
        {result, Map.put(new_cache, towel_key, result)}

      cached_result ->
        {cached_result, cache}
    end
  end

  defp find_all_options([], _, cache) do
    {1, cache}
  end

  defp calculate_options(towel, patterns, cache) do
    1..length(towel)
    |> Enum.reduce({0, cache}, fn len, {total, current_cache} ->
      str = towel |> Enum.take(len) |> Enum.join()

      case MapSet.member?(patterns, str) do
        true -> remaining = Enum.drop(towel, len)
        {sub_count, new_cache} = find_all_options(remaining, patterns, current_cache)
        {total + sub_count, new_cache}
        false-> {total, current_cache}
      end
    end)
  end

  def part2(file_name) do
    {patterns, towels} =
      File.stream!(file_name)
      |> Enum.map(&String.trim/1)
      |> parse_input(true, {MapSet.new(), []})

    towels
    |> Enum.reverse()
    |> Enum.filter(fn towel ->
      check_towel(String.graphemes(towel), patterns)
    end)
    |> Enum.reduce(0, fn towel, result ->
      {new_result, _} = find_all_options(String.graphemes(towel), patterns, %{})

      result + new_result
    end)
  end
end

file_name = "./day19/input.txt"
IO.inspect(Day19.part1(file_name))
IO.inspect(Day19.part2(file_name))
