defmodule Solution do
  # 2692315
  def solve1(file \\ "./input.txt") do
    data = get_data(file)

    do_solve1(data, Map.fetch!(data, 0), 0)
    |> Map.fetch!(0)
  end

  defp do_solve1(data, 99, _index) do
    data
  end

  defp do_solve1(data, opcode, index) when opcode in [1, 2] do
    op1 = Map.fetch!(data, Map.fetch!(data, index + 1))
    op2 = Map.fetch!(data, Map.fetch!(data, index + 2))

    result =
      case opcode do
        1 ->
          op1 + op2

        2 ->
          op1 * op2
      end

    data = Map.put(data, Map.fetch!(data, index + 3), result)

    do_solve1(data, Map.fetch!(data, index + 4), index + 4)
  end

  # Reads the file and parses it into a usable format
  defp get_data(file) do
    file
    |> File.read!()
    |> String.trim_trailing("\n")
    |> String.split(",")
    |> Enum.with_index()
    # Use a map to address memory efficiently
    |> Map.new(fn {e, i} -> {i, String.to_integer(e)} end)
  end

  # {95, 7}
  # 9507
  def solve2(file \\ "./input.txt") do
    data = get_data(file)

    for noun <- 0..99, verb <- 0..99, reduce: nil do
      # Only try as long we don't have an answer
      nil ->
        data =
          data
          |> Map.put(1, noun)
          |> Map.put(2, verb)

        case do_solve1(data, Map.fetch!(data, 0), 0) |> Map.fetch!(0) do
          19_690_720 ->
            # {noun, verb}
            100 * noun + verb

          _other ->
            nil
        end

      # Otherwise noop
      other ->
        other
    end
  end
end
