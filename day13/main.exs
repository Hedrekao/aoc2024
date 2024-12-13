defmodule Day13 do
  defp create_equations([hd | tail], current_equation, equations, is_part2) do
    case hd do
      "" ->
        create_equations(tail, [[], []], [current_equation | equations], is_part2)

      _ ->
        [indicator, values] = String.split(hd, ": ")
        [x_str, y_str] = String.split(values, ", ")

        case indicator do
          "Prize" ->
            x_value = String.split(x_str, "=") |> List.last() |> String.to_integer()
            y_value = String.split(y_str, "=") |> List.last() |> String.to_integer()

            {new_x_value, new_y_value} =
              case is_part2 do
                true -> {x_value + 10_000_000_000_000, y_value + 10_000_000_000_000}
                false -> {x_value, y_value}
              end

            first_equation = [new_x_value | Enum.at(current_equation, 0)]
            second_equation = [new_y_value | Enum.at(current_equation, 1)]
            new_equation = [first_equation, second_equation]
            create_equations(tail, new_equation, equations, is_part2)

          _ ->
            x_value = String.split(x_str, "+") |> List.last() |> String.to_integer()
            y_value = String.split(y_str, "+") |> List.last() |> String.to_integer()

            first_equation = [x_value | Enum.at(current_equation, 0)]
            second_equation = [y_value | Enum.at(current_equation, 1)]
            new_equation = [first_equation, second_equation]
            create_equations(tail, new_equation, equations, is_part2)
        end
    end
  end

  defp create_equations([], current_equation, equations, _) do
    [current_equation | equations]
  end

  defp solve_equations([hd | tail], acc) do
    [first_equation, second_equation] = hd
    [result1, first_x, first_y] = first_equation
    [result2, second_x, second_y] = second_equation

    det = first_x * second_y - first_y * second_x

    case det do
      0 ->
        solve_equations(tail, acc)

      _ ->
        # Cramer's rule (linear algebra yayy)
        x = (result1 * second_y - result2 * first_y) / det
        y = (first_x * result2 - second_x * result1) / det

        case {x, y} do
          {x, y} when x != trunc(x) * 1.0 or y != trunc(y) * 1.0 or x < 0 or y < 0 ->
            solve_equations(tail, acc)

          _ ->
            solve_equations(tail, x + y * 3 + acc)
        end
    end
  end

  defp solve_equations([], acc) do
    acc
  end

  def part1(file_name) do
    File.stream!(file_name)
    |> Enum.map(&String.trim/1)
    |> create_equations([[], []], [], false)
    |> solve_equations(0)
  end

  def part2(file_name) do
    File.stream!(file_name)
    |> Enum.map(&String.trim/1)
    |> create_equations([[], []], [], true)
    |> solve_equations(0)
  end
end

file_name = "./day13/input.txt"
IO.inspect(Day13.part1(file_name))
IO.inspect(Day13.part2(file_name))
