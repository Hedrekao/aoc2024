defmodule Day8 do
  defp find_antennas(data) do
    find_antennas_rec(data, 0, 0, %{})
  end

  defp find_antennas_rec(data, x, y, map) do
    width = length(hd(data))
    height = length(data)
    char = Enum.at(Enum.at(data, y), x)

    map =
      case char do
        "." -> map
        char -> Map.update(map, char, [{x, y}], &(&1 ++ [{x, y}]))
      end

    case {x, y} do
      {x, y} when x == width - 1 and y == height - 1 ->
        map

      {x, y} when x == width - 1 ->
        find_antennas_rec(data, 0, y + 1, map)

      _ ->
        find_antennas_rec(data, x + 1, y, map)
    end
  end

  def part1(file_name) do
    data =
      File.stream!(file_name)
      |> Enum.map(&String.trim/1)
      |> Enum.map(&String.graphemes/1)

    data
    |> find_antennas()
    |> Map.values()
    |> Enum.reduce(MapSet.new(), fn list, acc ->
      width = length(hd(data))
      height = length(data)

      set =
        for cord1 <- list,
            cord2 <- list,
            {x1, y1} = cord1,
            {x2, y2} = cord2,
            distx = x1 - x2,
            disty = y1 - y2,
            new_x = x1 + distx,
            new_y = y1 + disty,
            cord1 != cord2,
            new_x >= 0,
            new_x < width,
            new_y >= 0,
            new_y < height,
            into: MapSet.new() do
          {new_x, new_y}
        end

      MapSet.union(acc, set)
    end)
    |> MapSet.size()
  end

  defp check_options_rec({x, y}, dx, dy, width, height, set) do
    next_point = {x + dx, y + dy}

    should_finish =
      case next_point do
        {x, _} when x >= width or x < 0 ->
          true

        {_, y} when y >= height or y < 0 ->
          true

        _ ->
          false
      end

    if should_finish do
      set
    else
      check_options_rec(next_point, dx, dy, width, height, MapSet.put(set, next_point))
    end
  end

  def part2(file_name) do
    data =
      File.stream!(file_name)
      |> Enum.map(&String.trim/1)
      |> Enum.map(&String.graphemes/1)

    data
    |> find_antennas()
    |> Map.values()
    |> Enum.reduce(MapSet.new(), fn list, acc ->
      width = length(hd(data))
      height = length(data)

      options =
        for cord1 <- list,
            cord2 <- list,
            {x1, y1} = cord1,
            {x2, y2} = cord2,
            dx = x1 - x2,
            dy = y1 - y2,
            cord1 != cord2,
            into: [] do
          {cord1, {dx, dy}}
        end

      set =
        options
        |> Enum.reduce(MapSet.new(), fn {cord1, {dx, dy}}, acc ->
          check_options_rec(cord1, dx, dy, width, height, MapSet.new()) |> MapSet.union(acc)
        end)

      list |> MapSet.new() |> MapSet.union(set) |> MapSet.union(acc)
    end)
    |> MapSet.size()
  end
end

file_name = "./day8/input.txt"
IO.inspect(Day8.part1(file_name))
IO.inspect(Day8.part2(file_name))
