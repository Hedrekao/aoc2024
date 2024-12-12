defmodule Day12 do
  defp get_valid_neighbours(data, {x, y}, letter) do
    width = length(hd(data))
    height = length(data)
    dirs = [{1, 0}, {0, 1}, {-1, 0}, {0, -1}]

    dirs
    |> Enum.map(fn {dx, dy} -> {x + dx, y + dy} end)
    |> Enum.filter(fn {new_x, new_y} ->
      new_x >= 0 and new_x < width and
        new_y >= 0 and new_y < height and
        Enum.at(Enum.at(data, new_y), new_x) == letter
    end)
  end

  defp region_bfs(data, start, letter) do
    bfs_rec(data, [start], MapSet.new([start]), letter, [start])
  end

  defp bfs_rec(data, positions, visited, letter, acc) when length(positions) > 0 do
    next_positions =
      positions
      |> Enum.flat_map(fn pos -> get_valid_neighbours(data, pos, letter) end)
      |> Enum.filter(fn pos -> not MapSet.member?(visited, pos) end)
      |> Enum.uniq()

    new_visited = MapSet.union(visited, MapSet.new(next_positions))

    bfs_rec(data, next_positions, new_visited, letter, acc ++ next_positions)
  end

  defp bfs_rec(_, [], visited, _, acc) do
    {acc, visited}
  end

  defp find_regions(data, pos, visited, acc) do
    width = length(hd(data))
    height = length(data)
    {x, y} = pos

    is_visited = MapSet.member?(visited, pos)

    {new_acc, new_visited} =
      case is_visited do
        true ->
          {acc, visited}

        false ->
          {region, region_visited} = region_bfs(data, pos, Enum.at(Enum.at(data, y), x))
          {[region | acc], MapSet.union(visited, region_visited)}
      end

    case {x, y} do
      {x, y} when x == width - 1 and y == height - 1 ->
        new_acc

      {x, y} when x == width - 1 ->
        find_regions(data, {0, y + 1}, new_visited, new_acc)

      _ ->
        find_regions(data, {x + 1, y}, new_visited, new_acc)
    end
  end

  defp calculate_cost1(region) do
    area = length(region)
    region_set = MapSet.new(region)

    perimeter =
      region
      |> Enum.reduce(0, fn {x, y}, acc ->
        dirs = [{1, 0}, {0, 1}, {-1, 0}, {0, -1}]

        Enum.reduce(dirs, acc, fn {dx, dy}, acc2 ->
          new_x = x + dx
          new_y = y + dy

          if MapSet.member?(region_set, {new_x, new_y}) do
            acc2
          else
            acc2 + 1
          end
        end)
      end)

    area * perimeter
  end

  def part1(file_name) do
    File.stream!(file_name)
    |> Enum.map(&String.trim/1)
    |> Enum.map(&String.graphemes/1)
    |> find_regions({0, 0}, MapSet.new(), [])
    |> Enum.reduce(0, fn region, acc -> acc + calculate_cost1(region) end)
  end

  defp calculate_cost2(region) do
    area = length(region)
    region_set = MapSet.new(region)

    side_graphs = region
      |> Enum.reduce(%{}, fn {x, y}, acc ->
        dirs = [{1, 0}, {0, 1}, {-1, 0}, {0, -1}]

        Enum.reduce(dirs, acc, fn {dx, dy}, acc2 ->
          new_x = x + dx
          new_y = y + dy

          if MapSet.member?(region_set, {new_x, new_y}) do
            acc2
          else
            case {dx, dy} do
              {1, 0} -> Map.update(acc2, "x#{x}", [{x,y}], &(&1 ++ [{x,y}]))
              {0, 1} -> Map.update(acc2, "y#{y}", [{x,y}], &(&1 ++ [{x,y}]))
              {-1, 0} -> Map.update(acc2, "x#{new_x}", [{x,y}], &(&1 ++ [{x,y}]))
              {0, -1} -> Map.update(acc2, "y#{new_y}", [{x,y}], &(&1 ++ [{x,y}]))
            end
          end
        end)
      end)

    n_sides = side_graphs
      |> Enum.reduce(0, fn {_, values}, acc ->

        acc + bfs_disconnected(values, values, MapSet.new(), 0)
      end)

    area * n_sides
  end

  defp bfs_disconnected([hd | tail], positions, visited, acc) do

    is_visited = MapSet.member?(visited, hd)

    case is_visited do
      true ->
        bfs_disconnected(tail, positions, visited, acc)

      false ->
        new_visited = bfs_disconnected_rec(positions, [hd], MapSet.new())
        bfs_disconnected(tail, positions, MapSet.union(visited, new_visited), acc + 1)
    end
  end

  defp bfs_disconnected([], _, _, acc) do
    acc
  end

  defp bfs_disconnected_rec(data, positions, visited) when length(positions) > 0 do

    dirs = [{1, 0}, {0, 1}, {-1, 0}, {0, -1}]
    next_positions =
      positions
      |> Enum.flat_map(fn pos ->
        {x, y} = pos
        dirs
        |> Enum.map(fn {dx, dy} -> {x + dx, y + dy} end)
        |> Enum.filter(fn {new_x, new_y} ->
            {new_x, new_y} in data
          end)
      end)
      |> Enum.filter(fn pos -> not MapSet.member?(visited, pos) end)
      |> Enum.uniq()

    new_visited = MapSet.union(visited, MapSet.new(next_positions))

    bfs_disconnected_rec(data, next_positions, new_visited)
  end

  defp bfs_disconnected_rec(_, [], visited) do
    visited
  end

  def part2(file_name) do
    File.stream!(file_name)
    |> Enum.map(&String.trim/1)
    |> Enum.map(&String.graphemes/1)
    |> find_regions({0, 0}, MapSet.new(), [])
    |> Enum.reduce(0, fn region, acc -> acc + calculate_cost2(region) end)
  end
end

file_name = "./day12/input.txt"
IO.inspect(Day12.part1(file_name))
IO.inspect(Day12.part2(file_name))
