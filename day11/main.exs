defmodule Day11 do
  defp handle_blink([hd | tail], acc) do
    digits =
      hd
      |> Integer.digits()

    is_even = Enum.count(digits) |> rem(2) == 0

    case hd do
      0 ->
        handle_blink(tail, [1 | acc])

      _ when is_even ->
        len = Enum.count(digits)
        first_half = Enum.take(digits, div(len, 2)) |> Enum.join() |> String.to_integer()
        second_half = Enum.drop(digits, div(len, 2)) |> Enum.join() |> String.to_integer()
        handle_blink(tail, [second_half | [first_half | acc]])

      _ ->
        handle_blink(tail, [hd * 2024 | acc])
    end
  end

  defp handle_blink([], acc) do
    Enum.reverse(acc)
  end

  def part1(file_name) do
    data =
      File.stream!(file_name)
      |> Enum.map(&String.trim/1)
      |> Enum.map(&String.split(&1, " ", trim: true))
      |> List.flatten()
      |> Enum.map(&String.to_integer/1)

    Enum.reduce(0..24, data, fn _, acc ->
      handle_blink(acc, [])
    end)
    |> Enum.count()
  end

  defp handle_blink2([{key, val} | tail], cache, acc) do
    is_member = Map.has_key?(cache, key)

    case is_member do
      true ->
        values = Map.get(cache, key)

        new_acc =
          Enum.reduce(values, acc, fn x, acc_tmp ->
            Map.update(acc_tmp, x, val, &(&1 + val))
          end)

        handle_blink2(tail, cache, new_acc)

      false ->
        digits =
          key
          |> Integer.digits()

        is_even = Enum.count(digits) |> rem(2) == 0

        case key do
          0 ->
            new_cache = Map.put(cache, 0, [1])
            new_acc = Map.update(acc, 1, val, &(&1 + val))
            handle_blink2(tail, new_cache, new_acc)

          _ when is_even ->
            len = Enum.count(digits)
            first_half = Enum.take(digits, div(len, 2)) |> Enum.join() |> String.to_integer()
            second_half = Enum.drop(digits, div(len, 2)) |> Enum.join() |> String.to_integer()
            new_cache = Map.put(cache, key, [second_half, first_half])
            new_acc = Map.update(acc, second_half, val, &(&1 + val))
            new_acc = Map.update(new_acc, first_half, val, &(&1 + val))
            handle_blink2(tail, new_cache, new_acc)

          _ ->
            new_cache = Map.put(cache, key, [key * 2024])
            new_acc = Map.update(acc, key * 2024, val, &(&1 + val))
            handle_blink2(tail, new_cache, new_acc)
        end
    end
  end

  defp handle_blink2([], cache, acc) do
    {acc, cache}
  end

  def part2(file_name) do
    data =
      File.stream!(file_name)
      |> Enum.map(&String.trim/1)
      |> Enum.map(&String.split(&1, " ", trim: true))
      |> List.flatten()
      |> Enum.map(&String.to_integer/1)

    map =
      Enum.reduce(data, %{}, fn x, acc ->
        Map.put(acc, x, 1)
      end)

    {final_map, _} =
      Enum.reduce(0..74, {map, %{}}, fn _, {acc, cache} ->
        acc |> Map.to_list() |> handle_blink2(cache, %{})
      end)

    final_map
    |> Map.values()
    |> Enum.sum()
  end
end

file_name = "./day11/input.txt"
IO.inspect(Day11.part1(file_name))
IO.inspect(Day11.part2(file_name))
