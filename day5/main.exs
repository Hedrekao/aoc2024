defmodule Day5 do
  defp parse_rules([hd | tl], rules) do
    case hd do
      "" ->
        {tl, rules}

      _ ->
        [firstNum, secondNum] = hd |> String.split("|") |> Enum.map(&String.to_integer/1)
        rules = Map.update(rules, firstNum, [secondNum], &(&1 ++ [secondNum]))
        parse_rules(tl, rules)
    end
  end

  defp check_rules([], _) do
    true
  end

  defp check_rules([hd | tl], rules) do
    list2 = Map.get(rules, hd, [])

    case Enum.any?(tl, &(&1 in list2)) do
      false ->
        check_rules(tl, rules)

      true ->
        false
    end
  end

  def part1(file_name) do
    {updates, rules} =
      File.stream!(file_name)
      |> Enum.map(&String.trim/1)
      |> parse_rules(%{})

    updates
    |> Enum.reduce(0, fn update, acc ->
      numbers = update |> String.split(",") |> Enum.map(&String.to_integer/1)
      length = Enum.count(numbers)
      middle = div(length, 2)
      middleNumber = numbers |> Enum.at(middle)

      case check_rules(Enum.reverse(numbers), rules) do
        true ->
          acc + middleNumber

        false ->
          acc
      end
    end)
  end

  def sort_topological(numbers, rules) do
    {result, _} =
      Enum.reduce(
        numbers,
        {[], MapSet.new()},
        fn _, {acc, visited} -> visit(rules, numbers, acc, visited) end
      )

    result
  end

  defp visit(_, [], acc, visited), do: {acc, visited}

  defp visit(rules, [node | rest], acc, visited) do
    if MapSet.member?(visited, node) do
      visit(rules, rest, acc, visited)
    else
      visited = MapSet.put(visited, node)

      {new_acc, new_visited} =
        case Map.get(rules, node, []) do
          [] ->
            {[node | acc], visited}

          deps ->
            # Only visit dependencies that are in our number list
            deps = Enum.filter(deps, &(&1 in rest))
            {acc2, visited2} = visit(rules, deps, acc, visited)
            {[node | acc2], visited2}
        end

      visit(rules, rest, new_acc, new_visited)
    end
  end

  def part2(file_name) do
    {updates, rules} =
      File.stream!(file_name)
      |> Enum.map(&String.trim/1)
      |> parse_rules(%{})

    updates
    |> Enum.filter(fn update ->
      numbers = update |> String.split(",") |> Enum.map(&String.to_integer/1)
      not check_rules(Enum.reverse(numbers), rules)
    end)
    |> Enum.map(fn update ->
      update |> String.split(",") |> Enum.map(&String.to_integer/1)
    end)
    |> Enum.map(&sort_topological(&1, rules))
    |> Enum.reduce(0, fn list, acc ->
      length = Enum.count(list)
      middle = div(length, 2)
      middleNumber = list |> Enum.at(middle)
      acc + middleNumber
    end)
  end
end

file_name = "./day5/input.txt"
IO.inspect(Day5.part1(file_name))
IO.inspect(Day5.part2(file_name))
