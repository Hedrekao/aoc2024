defmodule Day10 do
  defp get_starting_positions(data, x, y, acc) do
    width = length(hd(data))
    height = length(data)

    should_finish =
      case {x, y} do
        {x, _} when x >= width or x < 0 ->
          true

        {_, y} when y >= height or y < 0 ->
          true

        _ ->
          false
      end

    if should_finish do
      acc
    else
      new_acc =
        case Enum.at(Enum.at(data, y), x) do
          "0" ->
            [{x, y} | acc]

          _ ->
            acc
        end

      case {x, y} do
        {x, y} when x == width - 1 and y == height - 1 ->
          new_acc

        {x, y} when x == width - 1 ->
          get_starting_positions(data, 0, y + 1, new_acc)

        _ ->
          get_starting_positions(data, x + 1, y, new_acc)
      end
    end
  end

  defp trail_bfs(data, pos) do
    bfs_rec(data, [pos], MapSet.new([pos]), 0, [1])
  end

  defp bfs_rec(_, [], _, _, acc) do
    acc
  end

  defp bfs_rec(data, positions, visited, current_level, acc) do
    case current_level do
      9 ->
        acc

      _ ->
        next_level =
          positions
          |> Enum.flat_map(fn pos -> get_valid_neighbours(data, pos, current_level) end)
          |> Enum.filter(fn pos -> not MapSet.member?(visited, pos) end)
          |> Enum.uniq()

        new_visited = MapSet.union(visited, MapSet.new(next_level))

        bfs_rec(data, next_level, new_visited, current_level + 1, [
          Enum.count(next_level) | acc
        ])
    end
  end

  defp get_valid_neighbours(data, {x, y}, current_level) do
    width = length(hd(data))
    height = length(data)
    dirs = [{1, 0}, {0, 1}, {-1, 0}, {0, -1}]

    dirs
    |> Enum.map(fn {dx, dy} -> {x + dx, y + dy} end)
    |> Enum.filter(fn {new_x, new_y} ->
      new_x >= 0 and new_x < width and
        new_y >= 0 and new_y < height and
        String.to_integer(Enum.at(Enum.at(data, new_y), new_x)) == current_level + 1
    end)
  end

  def part1(file_name) do
    data =
      File.stream!(file_name)
      |> Enum.map(&String.trim/1)
      |> Enum.map(&String.graphemes/1)

    data
    |> get_starting_positions(0, 0, [])
    |> Enum.reduce(0, fn pos, acc ->
      levels = trail_bfs(data, pos)
      len = length(levels)

      cond do
        len == 10 ->
          acc + Enum.at(levels, 0)

        true ->
          acc
      end
    end)
  end

  def count_paths(data, start_pos) do
    bfs_rec2(data, [start_pos], %{start_pos => 1}, 0, [1])
  end

  defp bfs_rec2(_, [], _, _, acc) do
    acc
  end

  defp bfs_rec2(data, positions, paths_map, current_level, acc) do
    case current_level do
      9 ->
        acc

      _ ->
        {next_cells, new_path_counts} =
          positions
          |> Enum.reduce({MapSet.new(), paths_map}, fn pos, {cells_acc, counts_acc} ->
            paths_to_current = Map.get(counts_acc, pos)

            neighbors = get_valid_neighbours(data, pos, current_level)

            Enum.reduce(neighbors, {cells_acc, counts_acc}, fn neighbor,
                                                               {cells_acc2, counts_acc2} ->
              new_cells = MapSet.put(cells_acc2, neighbor)

              new_counts =
                Map.update(counts_acc2, neighbor, paths_to_current, &(&1 + paths_to_current))

              {new_cells, new_counts}
            end)
          end)

        next_level = MapSet.to_list(next_cells)

        total_paths = Enum.sum(Enum.map(next_level, &Map.get(new_path_counts, &1)))
        bfs_rec2(data, next_level, new_path_counts, current_level + 1, [total_paths | acc])
    end
  end

  def part2(file_name) do
    data =
      File.stream!(file_name)
      |> Enum.map(&String.trim/1)
      |> Enum.map(&String.graphemes/1)

    data
    |> get_starting_positions(0, 0, [])
    |> Enum.reduce(0, fn pos, acc ->
      levels = count_paths(data, pos)
      len = length(levels)

      cond do
        len == 10 ->
          acc + Enum.at(levels, 0)

        true ->
          acc
      end
    end)
  end
end

file_name = "./day10/input.txt"
IO.inspect(Day10.part1(file_name))
IO.inspect(Day10.part2(file_name))
