defmodule Day9 do
  defp analyze_input([], _, _, acc) do
    Enum.reverse(acc)
  end

  defp analyze_input([hd | tail], is_file, counter, acc) do
    case is_file do
      true ->
        case hd do
          0 ->
            analyze_input(tail, !is_file, counter + 1, acc)

          _ ->
            analyze_input(tail, !is_file, counter + 1, [{counter, hd} | acc])
        end

      false ->
        case hd do
          0 ->
            analyze_input(tail, !is_file, counter, acc)

          _ ->
            analyze_input(tail, !is_file, counter, [{-1, hd} | acc])
        end
    end
  end

  defp reformat_disk([], _, _, _, acc) do
    Enum.reverse(acc)
  end

  defp reformat_disk([hd | tail], [hd_rev | tail_rev], idx, idx_rev, acc) do
    {counter, value} = hd
    {counter_rev, value_rev} = hd_rev

    cond do
      idx > idx_rev ->
        Enum.reverse(acc)

      idx == idx_rev and counter != -1 ->
        Enum.reverse([{counter, value_rev} | acc])

      true ->
        case counter do
          -1 ->
            case counter_rev do
              -1 ->
                reformat_disk([hd | tail], tail_rev, idx, idx_rev - 1, acc)

              _ ->
                diff = value - value_rev

                cond do
                  diff == 0 ->
                    reformat_disk(tail, tail_rev, idx + 1, idx_rev - 1, [
                      {counter_rev, value_rev} | acc
                    ])

                  diff > 0 ->
                    reformat_disk([{counter, diff} | tail], tail_rev, idx, idx_rev - 1, [
                      {counter_rev, value_rev} | acc
                    ])

                  diff < 0 ->
                    reformat_disk(
                      tail,
                      [{counter_rev, value_rev - value} | tail_rev],
                      idx + 1,
                      idx_rev,
                      [
                        {counter_rev, value} | acc
                      ]
                    )
                end
            end

          _ ->
            reformat_disk(tail, [hd_rev | tail_rev], idx + 1, idx_rev, [hd | acc])
        end
    end
  end

  defp calculate_checksum([], _, acc) do
    acc
  end

  defp calculate_checksum([hd | tail], position, acc) do
    {counter, value} = hd

    cond do
      counter == -1 ->
        calculate_checksum(tail, position, acc)

      true ->
        {new_val, position} =
          Enum.reduce(0..(value - 1), {0, position}, fn _, {acc, pos} ->
            {acc + pos * counter, pos + 1}
          end)

        calculate_checksum(tail, position, acc + new_val)
    end
  end

  def part1(file_name) do
    File.stream!(file_name)
    |> Enum.map(&String.trim/1)
    |> Enum.map(&String.graphemes/1)
    |> List.flatten()
    |> Enum.map(&String.to_integer/1)
    |> analyze_input(true, 0, [])
    |> then(&reformat_disk(&1, Enum.reverse(&1), 0, length(&1) - 1, []))
    |> calculate_checksum(0, 0)
  end

  defp analyze_input2([], _, _, _, files_acc, space_acc) do
    {files_acc, Enum.reverse(space_acc)}
  end

  defp analyze_input2([hd | tail], is_file, counter, pos, files_acc, space_acc) do
    case is_file do
      true ->
        case hd do
          0 ->
            analyze_input2(tail, !is_file, counter + 1, pos, files_acc, space_acc)

          _ ->
            analyze_input2(
              tail,
              !is_file,
              counter + 1,
              pos + hd,
              [{counter, pos + 1, pos + hd} | files_acc],
              space_acc
            )
        end

      false ->
        case hd do
          0 ->
            analyze_input2(tail, !is_file, counter, pos, files_acc, space_acc)

          _ ->
            analyze_input2(tail, !is_file, counter, pos + hd, files_acc, [
              {pos + 1, pos + hd} | space_acc
            ])
        end
    end
  end

  defp reformat_disk2([], _, acc) do
    Enum.reverse(acc)
  end

  defp reformat_disk2([hd | tail], spaces, acc) do
    {item, new_spaces} = change_pos(hd, spaces, 0, spaces)

    reformat_disk2(tail, new_spaces, [item | acc])
  end

  defp change_pos(item, [], _, spaces) do
    {item, spaces}
  end

  defp change_pos(file, [space | tail], space_pos, spaces) do
    {counter, start, stop} = file
    {space_start, space_stop} = space

    space_diff = space_stop - space_start + 1
    file_diff = stop - start + 1

    cond do
      space_start > stop ->
        change_pos(file, tail, space_pos + 1, spaces)

      true ->
        cond do
          space_diff == file_diff ->
            {{counter, space_start, space_stop}, List.delete_at(spaces, space_pos)}

          space_diff > file_diff ->
            {{counter, space_start, space_start + file_diff - 1},
             List.replace_at(spaces, space_pos, {space_start + file_diff, space_stop})}

          space_diff < file_diff ->
            change_pos(file, tail, space_pos + 1, spaces)
        end
    end
  end

  defp calculate_checksum2([], acc) do
    acc
  end

  defp calculate_checksum2([hd | tail], acc) do
    {counter, start, stop} = hd
    diff = stop - start

    new_val =
      Enum.reduce(0..diff, 0, fn i, tmp_acc ->
        tmp_acc + (start + i) * counter
      end)

    calculate_checksum2(tail, acc + new_val)
  end

  def part2(file_name) do
    {files, spaces} =
      File.stream!(file_name)
      |> Enum.map(&String.trim/1)
      |> Enum.map(&String.graphemes/1)
      |> List.flatten()
      |> Enum.map(&String.to_integer/1)
      |> analyze_input2(true, 0, -1, [], [])

    reformat_disk2(files, spaces, [])
    |> calculate_checksum2(0)
  end
end

file_name = "./day9/input.txt"
IO.inspect(Day9.part1(file_name))
IO.inspect(Day9.part2(file_name))
