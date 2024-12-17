defmodule Day16 do
  defp get_positions(grid, x, y, start_pos) do
    width = length(hd(grid))
    height = length(grid)

    new_start =
      case Enum.at(Enum.at(grid, y), x) do
        "S" ->
          {x, y}

        _ ->
          start_pos
      end

    case {x, y} do
      {x, y} when x == width - 1 and y == height - 1 ->
        new_start

      {x, y} when x == width - 1 ->
        get_positions(grid, 0, y + 1, new_start)

      _ ->
        get_positions(grid, x + 1, y, new_start)
    end
  end

  defp bfs_rec(_, [], _, acc) do
    acc
  end

  defp bfs_rec(grid, current_level, visited, acc) do
    width = length(hd(grid))
    height = length(grid)
    dirs = [{1, 0}, {0, 1}, {-1, 0}, {0, -1}]

    next_level =
      current_level
      |> Enum.flat_map(fn {x, y, current_dx, current_dy, points, cells} ->
        cond do
          acc != [] and points > Enum.min(acc) ->
            []

          true ->
            dirs
            |> Enum.map(fn {dx, dy} ->
              new_points =
                case {current_dx, current_dy} do
                  {^dx, ^dy} -> points + 1
                  {1, 0} when dx == 0 and dy == 1 -> points + 1000 + 1
                  {1, 0} when dx == 0 and dy == -1 -> points + 1000 + 1
                  {1, 0} when dx == -1 and dy == 0 -> points + 2000 + 1
                  {-1, 0} when dx == 0 and dy == 1 -> points + 1000 + 1
                  {-1, 0} when dx == 0 and dy == -1 -> points + 1000 + 1
                  {-1, 0} when dx == 1 and dy == 0 -> points + 2000 + 1
                  {0, 1} when dx == 1 and dy == 0 -> points + 1000 + 1
                  {0, 1} when dx == -1 and dy == 0 -> points + 1000 + 1
                  {0, 1} when dx == 0 and dy == -1 -> points + 2000 + 1
                  {0, -1} when dx == 1 and dy == 0 -> points + 1000 + 1
                  {0, -1} when dx == -1 and dy == 0 -> points + 1000 + 1
                  {0, -1} when dx == 0 and dy == 1 -> points + 2000 + 1
                end

              {x + dx, y + dy, dx, dy, new_points, [{x + dx, y + dy} | cells]}
            end)
        end
      end)
      |> Enum.filter(fn {x, y, dx, dy, points, _} ->
        best_points = Map.get(visited, {x, y, dx, dy}, 999_999)

        points < best_points and
          x >= 0 and x < width and y >= 0 and y < height and
          Enum.at(Enum.at(grid, y), x) !=
            "#"
      end)
      |> Enum.uniq()

    {new_acc, continues} =
      Enum.reduce(next_level, {acc, []}, fn {x, y, _, _, points, cells} = pos,
                                            {curr_acc, continues} ->
        case Enum.at(Enum.at(grid, y), x) do
          "E" -> {[{points, cells} | curr_acc], continues}
          _ -> {curr_acc, [pos | continues]}
        end
      end)

    new_visited =
      Enum.reduce(continues, visited, fn {x, y, dx, dy, points, _}, acc ->
        Map.put(acc, {x, y, dx, dy}, points)
      end)

    bfs_rec(grid, continues, new_visited, new_acc)
  end

  def part1(file_name) do
    grid =
      File.stream!(file_name)
      |> Enum.map(&String.trim/1)
      |> Enum.map(&String.graphemes/1)

    start_pos = get_positions(grid, 0, 0, nil)

    grid
    |> bfs_rec(
      [
        {elem(start_pos, 0), elem(start_pos, 1), 1, 0, 0,
         [{elem(start_pos, 0), elem(start_pos, 1)}]}
      ],
      %{start_pos => 0},
      []
    )
    |> Enum.map(&elem(&1, 0))
    |> Enum.min()
  end

  def part2(file_name) do
    grid =
      File.stream!(file_name)
      |> Enum.map(&String.trim/1)
      |> Enum.map(&String.graphemes/1)

    start_pos = get_positions(grid, 0, 0, nil)

    results =
      grid
      |> bfs_rec(
        [
          {elem(start_pos, 0), elem(start_pos, 1), 1, 0, 0,
           [{elem(start_pos, 0), elem(start_pos, 1)}]}
        ],
        %{start_pos => 0},
        []
      )

    min_steps = Enum.map(results, &elem(&1, 0)) |> Enum.min()

    results
    |> Enum.filter(fn {steps, _} -> steps == min_steps end)
    |> Enum.map(&elem(&1, 1))
    |> Enum.reduce(MapSet.new(), fn cells, acc -> MapSet.union(acc, MapSet.new(cells)) end)
    |> MapSet.size()
  end
end

file_name = "./day16/input.txt"
IO.inspect(Day16.part1(file_name))
IO.inspect(Day16.part2(file_name))
