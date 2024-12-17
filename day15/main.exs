defmodule Day15 do
  defp parse_input([], _, _, map, moves) do
    {map, Enum.reverse(moves)}
  end

  defp parse_input([line | rest], is_map, y, map, moves) do
    case line do
      [] ->
        parse_input(rest, !is_map, y, map, moves)

      _ ->
        case is_map do
          true ->
            new_map = parse_map(line, y, map)
            parse_input(rest, is_map, y + 1, new_map, moves)

          false ->
            new_moves = parse_moves(line, moves)
            parse_input(rest, is_map, y, map, new_moves)
        end
    end
  end

  defp parse_map(line, y, acc) do
    parse_map_rec(line, 0, y, acc)
  end

  defp parse_map_rec([], _, _, acc) do
    acc
  end

  defp parse_map_rec([char | rest], x, y, {walls, robot, boxes}) do
    case char do
      "#" -> parse_map_rec(rest, x + 1, y, {MapSet.put(walls, {x, y}), robot, boxes})
      "@" -> parse_map_rec(rest, x + 1, y, {walls, {x, y}, boxes})
      "O" -> parse_map_rec(rest, x + 1, y, {walls, robot, MapSet.put(boxes, {x, y})})
      _ -> parse_map_rec(rest, x + 1, y, {walls, robot, boxes})
    end
  end

  defp parse_moves(line, acc) do
    parse_moves_rec(line, acc)
  end

  defp parse_moves_rec([], acc) do
    acc
  end

  defp parse_moves_rec([char | rest], acc) do
    case char do
      "<" -> parse_moves_rec(rest, [{-1, 0} | acc])
      ">" -> parse_moves_rec(rest, [{1, 0} | acc])
      "^" -> parse_moves_rec(rest, [{0, -1} | acc])
      "v" -> parse_moves_rec(rest, [{0, 1} | acc])
    end
  end

  defp draw_board(walls, {robot_x, robot_y}, boxes) do
    IO.puts("")

    Enum.each(0..8, fn y ->
      Enum.each(0..8, fn x ->
        case {MapSet.member?(walls, {x, y}), {x, y} == {robot_x, robot_y},
              MapSet.member?(boxes, {x, y})} do
          {true, _, _} -> IO.write("#")
          {_, true, _} -> IO.write("@")
          {_, _, true} -> IO.write("O")
          _ -> IO.write(".")
        end
      end)

      IO.puts("")
    end)
  end

  defp move_robot({walls, {x, y}, boxes}, [{dx, dy} | rest]) do
    new_x = x + dx
    new_y = y + dy

    is_wall = MapSet.member?(walls, {new_x, new_y})
    is_box = MapSet.member?(boxes, {new_x, new_y})

    case {is_wall, is_box} do
      {true, _} ->
        move_robot({walls, {x, y}, boxes}, rest)

      {_, true} ->
        {new_boxes, new_robot} = move_box(walls, boxes, {dx, dy}, {new_x, new_y}, {x, y})
        move_robot({walls, new_robot, new_boxes}, rest)

      {_, _} ->
        move_robot({walls, {new_x, new_y}, boxes}, rest)
    end
  end

  defp move_robot(map, []) do
    map
  end

  defp move_box(walls, boxes, {dx, dy}, {next_x, next_y}, {x, y}) do
    next_next_x = next_x + dx
    next_next_y = next_y + dy

    is_wall = MapSet.member?(walls, {next_next_x, next_next_y})
    is_box = MapSet.member?(boxes, {next_next_x, next_next_y})

    case {is_wall, is_box} do
      {true, _} ->
        {boxes, {x, y}}

      {_, true} ->
        {new_boxes, pos} =
          move_box(walls, boxes, {dx, dy}, {next_next_x, next_next_y}, {next_x, next_y})

        final_boxes = MapSet.put(MapSet.delete(new_boxes, {next_x, next_y}), pos)

        cond do
          pos == {next_x, next_y} ->
            {final_boxes, {x, y}}

          true ->
            {final_boxes, {next_x, next_y}}
        end

      {_, _} ->
        {MapSet.put(MapSet.delete(boxes, {next_x, next_y}), {next_next_x, next_next_y}),
         {next_x, next_y}}
    end
  end

  def part1(file_name) do
    {map, moves} =
      File.stream!(file_name)
      |> Enum.map(&String.trim/1)
      |> Enum.map(&String.graphemes/1)
      |> parse_input(true, 0, {MapSet.new(), nil, MapSet.new()}, [])

    {_, _, boxes} = move_robot(map, moves)

    boxes
    |> Enum.reduce(0, fn {x, y}, acc -> acc + x + y * 100 end)
  end

  defp parse_input2([], _, _, map, moves) do
    {map, Enum.reverse(moves)}
  end

  defp parse_input2([line | rest], is_map, y, map, moves) do
    case line do
      [] ->
        parse_input2(rest, !is_map, y, map, moves)

      _ ->
        case is_map do
          true ->
            new_map = parse_map2(line, y, map)
            parse_input2(rest, is_map, y + 1, new_map, moves)

          false ->
            new_moves = parse_moves(line, moves)
            parse_input2(rest, is_map, y, map, new_moves)
        end
    end
  end

  defp parse_map2(line, y, acc) do
    parse_map_rec2(line, 0, y, acc)
  end

  defp parse_map_rec2([], _, _, acc) do
    acc
  end

  defp parse_map_rec2([char | rest], x, y, {walls, robot, boxes, boxes_pos}) do
    case char do
      "#" ->
        parse_map_rec2(
          rest,
          x + 2,
          y,
          {MapSet.put(walls, {x, y}) |> MapSet.put({x + 1, y}), robot, boxes, boxes_pos}
        )

      "@" ->
        parse_map_rec2(rest, x + 2, y, {walls, {x, y}, boxes, boxes_pos})

      "O" ->
        parse_map_rec2(
          rest,
          x + 2,
          y,
          {walls, robot, MapSet.put(boxes, {{x, y}, {x + 1, y}}),
           MapSet.put(boxes_pos, {x, y}) |> MapSet.put({x + 1, y})}
        )

      _ ->
        parse_map_rec2(rest, x + 2, y, {walls, robot, boxes, boxes_pos})
    end
  end

  defp draw_board2(walls, {robot_x, robot_y}, boxes) do
    IO.puts("")

    Enum.each(0..10, fn y ->
      Enum.each(0..20, fn x ->
        case {MapSet.member?(walls, {x, y}), {x, y} == {robot_x, robot_y},
              MapSet.member?(boxes, {{x, y}, {x + 1, y}}),
              MapSet.member?(boxes, {{x - 1, y}, {x, y}})} do
          {true, _, _, false} ->
            IO.write("#")

          {_, true, _, false} ->
            IO.write("@")

          {_, _, true, false} ->
            IO.write("[")

          {_, _, _, false} ->
            IO.write(".")

          {_, _, _, true} ->
            IO.write("]")
        end
      end)

      IO.puts("")
    end)
  end

  defp find_whole_box(boxes, {x, y}) do
    Enum.find(boxes, fn {{bx, by}, {ex, ey}} -> (bx == x && by == y) || (ex == x && ey == y) end)
  end

  defp move_robot2({walls, {x, y}, boxes, boxes_pos}, [{dx, dy} | rest]) do
    new_x = x + dx
    new_y = y + dy

    # draw_board2(walls, {x, y}, boxes)

    is_wall = MapSet.member?(walls, {new_x, new_y})
    is_box = MapSet.member?(boxes_pos, {new_x, new_y})

    case {is_wall, is_box} do
      {true, _} ->
        move_robot2({walls, {x, y}, boxes, boxes_pos}, rest)

      {_, true} ->
        {new_boxes, new_boxes_pos, new_robot} =
          case {dx, dy} do
            {_, dy} when dy == 0 ->
              move_box_h(walls, boxes, boxes_pos, dx, {new_x, new_y}, {x, y})

            _ ->
              move_box_v(walls, boxes, boxes_pos, dy, {new_x, new_y}, {x, y})
          end

        move_robot2({walls, new_robot, new_boxes, new_boxes_pos}, rest)

      {_, _} ->
        move_robot2({walls, {new_x, new_y}, boxes, boxes_pos}, rest)
    end
  end

  defp move_robot2(map, []) do
    map
  end

  defp move_box_v(walls, boxes, boxes_pos, dy, {next_x, next_y}, {x, y}) do
    whole_box = find_whole_box(boxes, {next_x, next_y})

    {{next_x1, next_y1}, {next_x2, next_y2}} = whole_box

    {left_boxes, left_boxes_pos, {_, left_y}} =
      move_half_box_v(walls, boxes, boxes_pos, dy, {next_x1, next_y1 + dy}, {next_x1, next_y1})

    {right_boxes, right_boxes_pos, {_, right_y}} =
      move_half_box_v(
        walls,
        left_boxes,
        left_boxes_pos,
        dy,
        {next_x2, next_y2 + dy},
        {next_x2, next_y2}
      )

    left_half_diff = abs(left_y - next_y1)
    right_half_diff = abs(right_y - next_y2)

    case {left_half_diff, right_half_diff} do
      {1, 1} ->
        final_boxes =
          right_boxes
          |> MapSet.delete(whole_box)
          |> MapSet.put({{next_x1, next_y1 + dy}, {next_x2, next_y2 + dy}})

        final_boxes_pos =
          right_boxes_pos
          |> MapSet.delete({next_x1, next_y1})
          |> MapSet.delete({next_x2, next_y2})
          |> MapSet.put({next_x1, next_y1 + dy})
          |> MapSet.put({next_x2, next_y2 + dy})

        {final_boxes, final_boxes_pos, {next_x, next_y}}

      {_, _} ->
        {boxes, boxes_pos, {x, y}}
    end
  end

  defp move_half_box_v(walls, boxes, boxes_pos, dy, {next_x, next_y}, {x, y}) do
    is_wall = MapSet.member?(walls, {next_x, next_y})
    is_box = MapSet.member?(boxes_pos, {next_x, next_y})

    case {is_wall, is_box} do
      {true, _} ->
        {boxes, boxes_pos, {x, y}}

      {_, true} ->
        move_box_v(walls, boxes, boxes_pos, dy, {next_x, next_y}, {x, y})

      {_, _} ->
        {boxes, boxes_pos, {next_x, next_y}}
    end
  end

  defp move_box_h(walls, boxes, boxes_pos, dx, {next_x, next_y}, {x, y}) do
    whole_box = find_whole_box(boxes, {next_x, next_y})

    {{next_x1, next_y1}, {next_x2, next_y2}} = whole_box

    next_next_x = next_x + dx
    next_next_y = next_y

    is_wall = MapSet.member?(walls, {next_next_x, next_next_y})
    is_box = MapSet.member?(boxes_pos, {next_next_x, next_next_y})

    case {is_wall, is_box} do
      {true, _} ->
        {boxes, boxes_pos, {x, y}}

      {_, true} ->
        {new_boxes, new_boxes_pos, pos} =
          move_box_h(walls, boxes, boxes_pos, dx, {next_next_x, next_next_y}, {next_x, next_y})

        {final_x, final_y} = pos
        is_done = MapSet.member?(new_boxes_pos, pos)

        {final_boxes, final_boxes_pos} =
          case is_done do
            true ->
              {new_boxes, new_boxes_pos}

            false ->
              tmp =
                cond do
                  dx == -1 -> {pos, {final_x - dx, final_y}}
                  dx == 1 -> {{final_x - dx, final_y}, pos}
                end

              {
                MapSet.delete(new_boxes, whole_box)
                |> MapSet.put(tmp),
                MapSet.delete(new_boxes_pos, {next_x1, next_y2})
                |> MapSet.delete({next_x2, next_y2})
                |> MapSet.put(pos)
                |> MapSet.put({final_x - dx, final_y})
              }
          end

        cond do
          pos == {next_x, next_y} ->
            {final_boxes, final_boxes_pos, {x, y}}

          true ->
            {final_boxes, final_boxes_pos, {next_x, next_y}}
        end

      {_, _} ->
        new_boxes =
          MapSet.delete(boxes, whole_box)
          |> MapSet.put({{next_x1 + dx, next_y1}, {next_x2 + dx, next_y2}})

        new_boxes_pos =
          MapSet.delete(boxes_pos, {next_x1, next_y1})
          |> MapSet.delete({next_x2, next_y2})
          |> MapSet.put({next_x1 + dx, next_y1})
          |> MapSet.put({next_x2 + dx, next_y2})

        {new_boxes, new_boxes_pos, {next_x, next_y}}
    end
  end

  def part2(file_name) do
    {map, moves} =
      File.stream!(file_name)
      |> Enum.map(&String.trim/1)
      |> Enum.map(&String.graphemes/1)
      |> parse_input2(true, 0, {MapSet.new(), nil, MapSet.new(), MapSet.new()}, [])

    {_, _, boxes, _} = move_robot2(map, moves)

    boxes
    |> Enum.reduce(0, fn {{x, y}, _}, acc -> acc + x + y * 100 end)
  end
end

file_name = "./day15/input.txt"
IO.inspect(Day15.part1(file_name))
IO.inspect(Day15.part2(file_name))
