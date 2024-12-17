defmodule Day17 do
  defp parse_input([line | lines], is_registers, {registers, instructions}) do
    case is_registers do
      true ->
        case line do
          "" ->
            parse_input(lines, !is_registers, {registers, instructions})

          _ ->
            register_value = String.split(line, ": ") |> List.last() |> String.to_integer()
            parse_input(lines, is_registers, {[register_value | registers], instructions})
        end

      false ->
        new_instructions =
          String.split(line, ": ")
          |> List.last()
          |> String.split(",")
          |> Enum.map(&String.to_integer/1)

        parse_input(lines, false, {registers, new_instructions})
    end
  end

  defp parse_input([], _, {registers, instructions}) do
    {Enum.reverse(registers), instructions}
  end

  defp run_program(registers, instructions) do
    run_program_rec(registers, instructions, 0, [])
  end

  defp run_program_rec(registers, instructions, index, acc) do
    case index do
      i when i < 0 or i >= length(instructions) ->
        acc

      _ ->
        opcode = Enum.at(instructions, index)
        operand = Enum.at(instructions, index + 1)
        registerA = Enum.at(registers, 0)
        registerB = Enum.at(registers, 1)
        registerC = Enum.at(registers, 2)

        {new_registers, new_index, new_acc} =
          case opcode do
            0 ->
              denumerator =
                case operand do
                  operand when operand in [0, 1, 2, 3] -> 2 ** operand
                  4 -> 2 ** registerA
                  5 -> 2 ** registerB
                  6 -> 2 ** registerC
                  _ -> 1
                end

              {[trunc(registerA / denumerator), registerB, registerC], index + 2, acc}

            1 ->
              {[registerA, Bitwise.bxor(registerB, operand), registerC], index + 2, acc}

            2 ->
              value =
                case operand do
                  operand when operand in [0, 1, 2, 3] -> rem(operand, 8)
                  4 -> rem(registerA, 8)
                  5 -> rem(registerB, 8)
                  6 -> rem(registerC, 8)
                  _ -> 0
                end

              {[registerA, value, registerC], index + 2, acc}

            3 ->
              cond do
                registerA == 0 -> {[registerA, registerB, registerC], index + 2, acc}
                true -> {[registerA, registerB, registerC], operand, acc}
              end

            4 ->
              {[registerA, Bitwise.bxor(registerB, registerC), registerC], index + 2, acc}

            5 ->
              value =
                case operand do
                  operand when operand in [0, 1, 2, 3] -> rem(operand, 8)
                  4 -> rem(registerA, 8)
                  5 -> rem(registerB, 8)
                  6 -> rem(registerC, 8)
                  _ -> 0
                end

              {[registerA, registerB, registerC], index + 2, [value | acc]}

            6 ->
              denumerator =
                case operand do
                  operand when operand in [0, 1, 2, 3] -> 2 ** operand
                  4 -> 2 ** registerA
                  5 -> 2 ** registerB
                  6 -> 2 ** registerC
                  _ -> 1
                end

              {[registerA, trunc(registerA / denumerator), registerC], index + 2, acc}

            7 ->
              denumerator =
                case operand do
                  operand when operand in [0, 1, 2, 3] -> 2 ** operand
                  4 -> 2 ** registerA
                  5 -> 2 ** registerB
                  6 -> 2 ** registerC
                  _ -> 1
                end

              {[registerA, registerB, trunc(registerA / denumerator)], index + 2, acc}
          end

        run_program_rec(new_registers, instructions, new_index, new_acc)
    end
  end

  def part1(file_name) do
    {registers, instructions} =
      File.stream!(file_name)
      |> Enum.map(&String.trim/1)
      |> parse_input(true, {[], []})

    run_program(registers, instructions) |> Enum.reverse() |> Enum.join(",")
  end

  defp search_rec(a, instructions, index) do
    registers = [a, 0, 0]
    program_output = run_program(registers, instructions)
    expected_output = Enum.reverse(instructions) |> Enum.take(index + 1)
    actual_output = program_output |> Enum.take(index + 1)

    cond do
      index >= length(instructions) ->
        a / 8

      actual_output == expected_output ->
        search_rec(a * 8, instructions, index + 1)

      true ->
        search_rec(a + 1, instructions, index)
    end
  end

  def part2(file_name) do
    {_, instructions} =
      File.stream!(file_name)
      |> Enum.map(&String.trim/1)
      |> parse_input(true, {[], []})

    search_rec(0, instructions, 0)
  end
end

file_name = "./day17/input.txt"
IO.inspect(Day17.part1(file_name))
IO.inspect(Day17.part2(file_name))
