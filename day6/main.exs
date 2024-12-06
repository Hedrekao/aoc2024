defmodule Day6 do
  defp map_map(data) do
    map_map_rec(data, 0, 0, {}, MapSet.new())
  end

  defp map_map_rec(data, x, y, guard, obstacles) do
    width = length(hd(data))
    height = length(data)
    char = Enum.at(Enum.at(data, y), x)

    {guard, obstacles} =
      case char do
        "^" ->
          {{x, y}, obstacles}

        "#" ->
          {guard, MapSet.put(obstacles, {x, y})}

        _ ->
          {guard, obstacles}
      end

    case {x, y} do
      {x, y} when x == width - 1 and y == height - 1 ->
        {guard, obstacles, data}

      {x, y} when x == width - 1 ->
        map_map_rec(data, 0, y + 1, guard, obstacles)

      _ ->
        map_map_rec(data, x + 1, y, guard, obstacles)
    end
  end

  def simulate({guard, obstacles, data}) do
    simulate_rec(data, guard, obstacles, 0, -1, MapSet.new(), [])
  end

  defp simulate_rec(data, guard, obstacles, dx, dy, visited, acc) do
    width = length(hd(data))
    height = length(data)

    should_finish =
      case guard do
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
      is_visited = MapSet.member?(visited, guard)

      {acc, visited} =
        case is_visited do
          true ->
            {acc, visited}

          false ->
            {[guard | acc], MapSet.put(visited, guard)}
        end

      {x, y} = guard
      next_guard = {x + dx, y + dy}

      is_obstacle = MapSet.member?(obstacles, next_guard)

      case is_obstacle do
        true ->
          {dx, dy} =
            case {dx, dy} do
              {0, -1} -> {1, 0}
              {1, 0} -> {0, 1}
              {0, 1} -> {-1, 0}
              {-1, 0} -> {0, -1}
            end

          simulate_rec(data, guard, obstacles, dx, dy, visited, acc)

        false ->
          simulate_rec(data, next_guard, obstacles, dx, dy, visited, acc)
      end
    end
  end

  def check_loop?(guard, obstacles, data) do
    check_loop_rec(data, guard, obstacles, 0, -1, MapSet.new())
  end

  defp check_loop_rec(data, guard, obstacles, dx, dy, visited) do
    width = length(hd(data))
    height = length(data)

    should_finish =
      case guard do
        {x, _} when x >= width or x < 0 ->
          true

        {_, y} when y >= height or y < 0 ->
          true

        _ ->
          false
      end

    if should_finish do
      false
    else
      {x, y} = guard
      next_guard = {x + dx, y + dy}
      is_obstacle = MapSet.member?(obstacles, next_guard)

      case is_obstacle do
        true ->
          is_visited = MapSet.member?(visited, {x, y, dx, dy})

          case is_visited do
            true ->
              true

            false ->
              new_visited = MapSet.put(visited, {x, y, dx, dy})

              {dx, dy} =
                case {dx, dy} do
                  {0, -1} -> {1, 0}
                  {1, 0} -> {0, 1}
                  {0, 1} -> {-1, 0}
                  {-1, 0} -> {0, -1}
                end

              check_loop_rec(data, guard, obstacles, dx, dy, new_visited)
          end

        false ->
          check_loop_rec(
            data,
            next_guard,
            obstacles,
            dx,
            dy,
            visited
          )
      end
    end
  end

  def part1(file_name) do
    File.stream!(file_name)
    |> Enum.map(&String.trim/1)
    |> Enum.map(&String.graphemes/1)
    |> map_map()
    |> simulate()
    |> Enum.count()
  end

  def part2(file_name) do
    {guard, obstacles, data} =
      File.stream!(file_name)
      |> Enum.map(&String.trim/1)
      |> Enum.map(&String.graphemes/1)
      |> map_map()

    possibilites = {guard, obstacles, data} |> simulate()

    possibilites
    |> Enum.filter(fn option -> !MapSet.member?(obstacles, option) end)
    |> Enum.filter(fn option -> guard != option end)
    |> Enum.reduce(0, fn option, acc ->
      new_obstacles = MapSet.put(obstacles, option)

      case check_loop?(guard, new_obstacles, data) do
        true -> acc + 1
        false -> acc
      end
    end)
  end
end

file_name = "./day6/input.txt"
IO.inspect(Day6.part1(file_name))
IO.inspect(Day6.part2(file_name))
