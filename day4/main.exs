defmodule Day4 do
  defp find_xmas(data) do
    find_xmas_rec(data, 0, 0, 0)
  end

  defp find_xmas_rec(data, acc, x, y) do
    width = length(hd(data))
    height = length(data)
    char = Enum.at(Enum.at(data, y), x)

    found =
      case char do
        "X" ->
          directions = [
            {1, 0},
            {0, 1},
            {1, 1},
            {-1, 1},
            {1, -1},
            {-1, -1},
            {0, -1},
            {-1, 0}
          ]

          results =
            directions
            |> Enum.map(fn {dx, dy} -> check_text(data, "", x, y, dx, dy) end)
            |> Enum.map(fn result -> if result, do: 1, else: 0 end)
            |> Enum.sum()

          results

        _ ->
          0
      end

    case {x, y} do
      {x, y} when x == width - 1 and y == height - 1 ->
        acc + found

      {x, y} when x == width - 1 ->
        find_xmas_rec(data, acc + found, 0, y + 1)

      _ ->
        find_xmas_rec(data, acc + found, x + 1, y)
    end
  end

  defp check_text(_, "XMAS", _, _, _, _) do
    true
  end

  defp check_text(data, text, x, y, dx, dy) do
    width = length(hd(data))
    height = length(data)

    # do bounds check
    should_exit =
      case {x, y} do
        {x, _} when x < 0 or x >= width ->
          true

        {_, y} when y < 0 or y >= height ->
          true

        _ ->
          false
      end

    if should_exit do
      false
    else
      char = Enum.at(Enum.at(data, y), x)

      case {text, char} do
        {"", "X"} -> check_text(data, "X", x + dx, y + dy, dx, dy)
        {"X", "M"} -> check_text(data, "XM", x + dx, y + dy, dx, dy)
        {"XM", "A"} -> check_text(data, "XMA", x + dx, y + dy, dx, dy)
        {"XMA", "S"} -> check_text(data, "XMAS", x + dx, y + dy, dx, dy)
        _ -> false
      end
    end
  end

  defp find_mas(data) do
    find_mas_rec(data, 0, 0, 0, MapSet.new())
  end

  defp find_mas_rec(data, acc, x, y, set) do
    width = length(hd(data))
    height = length(data)

    char = Enum.at(Enum.at(data, y), x)

    {found, set} =
      case char do
        "M" ->
          directions = [
            {1, 1},
            {-1, 1},
            {1, -1},
            {-1, -1}
          ]

          results =
            directions
            |> Enum.map(fn {dx, dy} -> check_text_mas(data, "", x, y, dx, dy, set, set) end)
            |> Enum.reduce({0, set}, fn {result, new_set}, {acc, set} ->
              {acc + result, MapSet.union(set, new_set)}
            end)

          results

        _ ->
          {0, set}
      end

    case {x, y} do
      {x, y} when x == width - 1 and y == height - 1 ->
        acc + found

      {x, y} when x == width - 1 ->
        find_mas_rec(data, acc + found, 0, y + 1, set)

      _ ->
        find_mas_rec(data, acc + found, x + 1, y, set)
    end
  end

  defp check_text_mas(data, text, x, y, dx, dy, set, og_set) do
    width = length(hd(data))
    height = length(data)

    # do bounds check
    should_exit =
      case {x, y} do
        {x, _} when x < 0 or x >= width ->
          true

        {_, y} when y < 0 or y >= height ->
          true

        _ ->
          false
      end

    if should_exit do
      {0, og_set}
    else
      char = Enum.at(Enum.at(data, y), x)

      case {text, char} do
        {"", "M"} ->
          check_text_mas(data, "M", x + dx, y + dy, dx, dy, set, og_set)

        {"M", "A"} ->
          if MapSet.member?(set, {x, y}) do
            {0, set}
          else
            check_text_mas(data, "MA", x + dx, y + dy, dx, dy, MapSet.put(set, {x, y}), og_set)
          end

        {"MA", "S"} ->
          check_text_mas(data, "MAS_", x - dx * 2, y, dx, dy * -1, set, og_set)

        {"MAS_", "M"} ->
          check_text_mas(data, "MAS_M", x + dx, y + dy, dx, dy, set, og_set)

        {"MAS_", "S"} ->
          check_text_mas(data, "MAS_S", x + dx, y + dy, dx, dy, set, og_set)

        {"MAS_M", "A"} ->
          check_text_mas(data, "MAS_MA", x + dx, y + dy, dx, dy, set, og_set)

        {"MAS_S", "A"} ->
          check_text_mas(data, "MAS_SA", x + dx, y + dy, dx, dy, set, og_set)

        {"MAS_MA", "S"} ->
          {1, set}

        {"MAS_SA", "M"} ->
          {1, set}

        _ ->
          {0, og_set}
      end
    end
  end

  def part1(file_name) do
    File.stream!(file_name)
    |> Enum.map(&String.trim/1)
    |> Enum.map(&String.graphemes/1)
    |> find_xmas()
  end

  def part2(file_name) do
    File.stream!(file_name)
    |> Enum.map(&String.trim/1)
    |> Enum.map(&String.graphemes/1)
    |> find_mas()
  end
end

file_name = "./day4/input.txt"
IO.inspect(Day4.part1(file_name))
IO.inspect(Day4.part2(file_name))
