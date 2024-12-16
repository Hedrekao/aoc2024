defmodule Day14 do

  defp move_robots(robots, time) do

    case time do
      100 -> robots
      _ ->
        move_robots(robots |> Enum.map(&move_robot(&1)), time + 1)

    end
  end

  defp move_robot([{x, y}, {dx, dy}]) do
    width = 101
    height = 103

    new_x = x + dx
    new_y = y + dy

    final_new_x = case new_x do
      x when x < 0 -> width + x
      x when x >= width -> x - width
      _ -> new_x
    end

    final_new_y = case new_y do
      y when y < 0 -> height + y
      y when y >= height -> y - height
      _ -> new_y
    end

    [{final_new_x, final_new_y}, {dx, dy}]
  end

  defp calculate_quadrants([robot | rest], acc) do

    [{x, y}, _] = robot

    quadrant = case {x, y} do
      {x, y} when x < 50 and y < 51 -> 0
      {x, y} when x > 50 and y < 51 -> 1
        {x, y} when x < 50 and y > 51 -> 2
      {x, y} when x > 50 and y > 51 -> 3
      _ -> -1
    end

    first_number = Enum.at(acc, 0)
    second_number = Enum.at(acc, 1)
    third_number = Enum.at(acc, 2)
    fourth_number = Enum.at(acc, 3)

    new_acc = case quadrant do
      0 -> [first_number + 1, second_number, third_number, fourth_number]
      1 -> [first_number, second_number + 1, third_number, fourth_number]
      2 -> [first_number, second_number, third_number + 1, fourth_number]
      3 -> [first_number, second_number, third_number, fourth_number + 1]
      _ -> [first_number, second_number, third_number, fourth_number]
    end


    calculate_quadrants(rest, new_acc)
  end

  defp calculate_quadrants([], acc) do
    acc
  end

  defp parse_input([], acc) do
    acc
  end

  defp parse_input([line | rest], acc) do
    [position_str, vel_str] = String.split(line, " ")

    [_, position] = String.split(position_str, "=")
    [_, vel] = String.split(vel_str, "=")

    [x, y] = String.split(position, ",") |> Enum.map(&String.trim/1) |> Enum.map(&String.to_integer/1)
    [dx, dy] = String.split(vel, ",") |> Enum.map(&String.trim/1) |> Enum.map(&String.to_integer/1)

    parse_input(rest, acc ++ [[{x, y}, {dx, dy}]])
  end

  def part1(file_name) do
   robots = File.stream!(file_name)
    |> Enum.map(&String.trim/1)
    |> parse_input([])

    move_robots(robots, 0)
    |> calculate_quadrants([0,0,0,0])
    |> Enum.reduce(1,
      fn x, acc ->
        acc * x end
    )
  end

  defp check_robots(robots) do
     robots
    |> Enum.group_by(fn [{_, y}, _] -> y end, fn [{x, _}, _] -> x end)
    |> Map.values()
    |> Enum.map(&Enum.sort(&1))
    |> Enum.reduce(false, fn x, acc ->

      new_acc = x
      |> Enum.chunk_every(10,1 , :discard)
      |> Enum.any?(fn chunk ->
        chunk
        |> Enum.chunk_every(2, 1, :discard)
        |> Enum.all?(fn [a, b] ->
          b == a + 1
        end)
      end
        )

      acc || new_acc
    end)

  end

  defp draw_grid(robots) do
    width = 101
    height = 103

    grid = Enum.map(0..height, fn y ->
      Enum.map(0..width, fn x ->
        case Enum.find(robots, fn [{x1, y1}, _] -> x1 == x and y1 == y end) do
          nil -> "."
          _ -> "#"
        end
      end)
    end)

    Enum.each(grid, fn row ->
      IO.puts(Enum.join(row, ""))
    end)
  end


  defp move_robots2(robots, time, acc) do

    case time do
      100000 -> acc
      _ ->
        new_robots = robots |> Enum.map(&move_robot(&1))

        new_time = time + 1
        new_acc = case check_robots(new_robots) do
          true -> Map.put(acc, new_time, new_robots)
          false -> acc
        end

        move_robots2(new_robots, new_time, new_acc)

    end

  end

  def part2(file_name) do
   robots = File.stream!(file_name)
    |> Enum.map(&String.trim/1)
    |> parse_input([])

    map = robots |> move_robots2(0, %{})

    map
    |> Enum.each(fn {time, robots} ->
      IO.puts("Time: #{time}")
      draw_grid(robots)
      IO.puts("----------------------------------")
      IO.puts("\n\n")
    end)

  end

end

file_name = "./day14/input.txt"
IO.inspect(Day14.part1(file_name))
IO.inspect(Day14.part2(file_name))
