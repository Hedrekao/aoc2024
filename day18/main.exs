defmodule Day18 do
  defp parse_bytes([line | rest], acc) do
    parse_bytes(
      rest,
      acc
      |> MapSet.put(
        line
        |> String.split(",")
        |> Enum.map(&String.to_integer/1)
        |> List.to_tuple()
      )
    )
  end

  defp parse_bytes([], acc) do
    acc
  end

  defp bfs_rec(walls, positions, visited) do
    width = 71
    height = 71

    directions = [{1, 0}, {0, 1}, {-1, 0}, {0, -1}]

    next_positions =
      positions
      |> Enum.flat_map(fn {x, y, level} ->
        Enum.map(directions, fn {dx, dy} -> {x + dx, y + dy, level + 1} end)
      end)
      |> Enum.filter(fn {new_x, new_y, _} ->
        new_x >= 0 and new_x < width and
          new_y >= 0 and new_y < height and
          not MapSet.member?(visited, {new_x, new_y}) and
          not MapSet.member?(walls, {new_x, new_y})
      end)
      |> Enum.uniq()

    new_visited =
      MapSet.union(visited, MapSet.new(Enum.map(next_positions, fn {x, y, _} -> {x, y} end)))

    case next_positions do
      [] ->
        nil

      _ ->
        reached_end = Enum.find(next_positions, fn {x, y, _} -> x == 70 and y == 70 end)

        case reached_end do
          nil -> bfs_rec(walls, next_positions, new_visited)
          {_, _, level} -> level
        end
    end
  end

  def part1(file_name) do
    walls =
      File.stream!(file_name)
      |> Enum.map(&String.trim/1)
      |> Enum.take(1024)
      |> parse_bytes(MapSet.new())

    bfs_rec(walls, [{0, 0, 0}], MapSet.new([{0, 0}]))
  end

  defp check_for_path(walls_list, n_walls) do
    walls =
      walls_list
      |> Enum.take(n_walls)
      |> parse_bytes(MapSet.new())

    case bfs_rec(walls, [{0, 0, 0}], MapSet.new([{0, 0}])) do
      nil -> Enum.at(walls_list, n_walls - 1)
      _ -> check_for_path(walls_list, n_walls + 1)
    end
  end

  def part2(file_name) do
    walls_list =
      File.stream!(file_name)
      |> Enum.map(&String.trim/1)

    check_for_path(walls_list, 1024)
  end
end

file_name = "./day18/input.txt"
IO.inspect(Day18.part1(file_name))
IO.inspect(Day18.part2(file_name))
