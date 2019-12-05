defmodule Solution do
  # Instructions
  @halt 99
  @add 1
  @mul 2
  @read 3
  @write 4
  @jit 5
  @jif 6
  @less_than 7
  @eq 8

  # Parameter Modes
  @position 0
  @immediate 1

  # Correct solution: 9775037
  # Input: 1
  def solve1(input, file \\ "./input.txt") do
    _solve(file, List.wrap(input))
  end

  # Correct solution: 15586959
  # Input: 5
  def solve2(input, file \\ "./input.txt") do
    _solve(file, List.wrap(input))
  end

  # Actually starts solving
  defp _solve(file, input) do
    data =
      file
      |> get_data()
      |> Map.put(:input, input)
      |> Map.put(:output, [])

    do_solve(data, Map.fetch!(data, 0), 0)
    |> Map.get(:output)
    |> Enum.reverse()
  end

  # Reads the compound-op into a tuple of {op, p1_mode, p2_mode, p3_mode}
  defp parse_op(op) do
    opcode = rem(op, 100)
    p1 = op |> div(100) |> rem(10)
    p2 = op |> div(1000) |> rem(10)
    p3 = op |> div(10000) |> rem(10)

    {opcode, p1, p2, p3}
  end

  # Reads a paramter given the index and mode
  defp read_parameter(data, index, mode) do
    tmp = Map.fetch!(data, index)

    case mode do
      @position ->
        Map.fetch!(data, tmp)

      @immediate ->
        tmp
    end
  end

  # Writes a parameter given the index and mode
  defp write_parameter(data, index, @position, value) do
    # The mode @immediate would not make sense, as can't write to a literal
    Map.put(data, Map.fetch!(data, index), value)
  end

  # Parse the op if necessary
  defp do_solve(data, op, index) when is_integer(op) do
    do_solve(data, parse_op(op), index)
  end

  # We are done here
  defp do_solve(data, {@halt, _, _, _}, _index) do
    data
  end

  # add and mul instructions
  defp do_solve(data, {opcode, p1, p2, p3}, index) when opcode in [@add, @mul] do
    op1 = read_parameter(data, index + 1, p1)
    op2 = read_parameter(data, index + 2, p2)

    result =
      case opcode do
        @add ->
          op1 + op2

        @mul ->
          op1 * op2
      end

    data = write_parameter(data, index + 3, p3, result)

    do_solve(data, Map.fetch!(data, index + 4), index + 4)
  end

  # read instruction
  defp do_solve(data, {@read, @position = p1, _, _}, index) do
    {[input], data} =
      Map.get_and_update!(data, :input, fn
        [_h] -> :pop
        [h | t] -> {[h], t}
      end)

    data = write_parameter(data, index + 1, p1, input)

    do_solve(data, Map.fetch!(data, index + 2), index + 2)
  end

  # Write instruction
  defp do_solve(data, {@write, p1, _, _}, index) do
    output = read_parameter(data, index + 1, p1)

    data = Map.update!(data, :output, &[output | &1])

    do_solve(data, Map.fetch!(data, index + 2), index + 2)
  end

  # jump if true and jump if false instructions
  defp do_solve(data, {opcode, p1, p2, _}, index) when opcode in [@jit, @jif] do
    condition = read_parameter(data, index + 1, p1)
    new_index = read_parameter(data, index + 2, p2)

    index =
      cond do
        opcode == @jit and condition != 0 ->
          new_index

        opcode == @jif and condition == 0 ->
          new_index

        true ->
          index + 3
      end

    do_solve(data, Map.fetch!(data, index), index)
  end

  # less than and equals instructions
  defp do_solve(data, {op, p1, p2, p3}, index) when op in [@less_than, @eq] do
    op1 = read_parameter(data, index + 1, p1)
    op2 = read_parameter(data, index + 2, p2)

    result =
      cond do
        op == @less_than and op1 < op2 ->
          1

        op == @eq and op1 == op2 ->
          1

        true ->
          0
      end

    data = write_parameter(data, index + 3, p3, result)

    do_solve(data, Map.fetch!(data, index + 4), index + 4)
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
end
