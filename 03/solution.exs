defmodule Solution do
  # Correct solution: 221
  def solve1(input \\ "./input.txt") do
    {x, y} =
      input
      |> stream_wires()
      # Convert to MapSets
      |> Stream.map(&MapSet.new(&1, fn {k, _v} -> k end))
      # Get the intersection points
      |> Enum.reduce(&MapSet.intersection/2)
      # Find the clostest
      |> Enum.min_by(fn {x, y} -> abs(x) + abs(y) end)

    abs(x) + abs(y)
  end

  # Correct solution: 18542
  def solve2(input \\ "./input.txt") do
    wires =
      input
      |> stream_wires()
      |> Enum.map(& &1)

    intersections =
      wires
      # Convert to MapSets
      |> Enum.map(&MapSet.new(&1, fn {k, _v} -> k end))
      # Get the intersection points
      |> Enum.reduce(&MapSet.intersection/2)
      # Convert to usable list
      |> MapSet.to_list()
      # Sum the distances of the wires together
      |> Enum.map(fn intersection ->
        Enum.reduce(wires, 0, fn wire, acc -> acc + Map.fetch!(wire, intersection) end)
      end)
      # Get the smallest one
      |> Enum.min()
  end

  defp stream_wires(file) do
    file
    |> File.stream!()
    # Trim trailing linebreak
    |> Stream.map(&binary_part(&1, 0, byte_size(&1) - 1))
    # Split by comma
    |> Stream.map(&String.split(&1, ","))
    # Convert to usable format
    # {direction, distance}
    |> Stream.map(
      &Enum.map(&1, fn <<direction::utf8, distance::binary>> ->
        {<<direction::utf8>>, String.to_integer(distance)}
      end)
    )
    # Gather all positions and lengths in a Map
    |> Stream.map(&do_run_wire/1)
  end

  # "Run" accross the wire and remember all of its positions and their minimal distances
  # {{x, y}, distance}
  defp do_run_wire(current \\ {{0, 0}, 0}, positions \\ Map.new(), wire)

  defp do_run_wire(_current, positions, []), do: positions |> Map.delete({0, 0})

  defp do_run_wire({{x, y}, wire_length}, positions, [{direction, distance} | tail]) do
    new_position = {to_x, to_y} = get_new_position({x, y}, direction, distance)

    new_positions =
      for new_x <- x..to_x, new_y <- y..to_y do
        {new_x, new_y}
      end
      # Add the new distances
      |> Enum.with_index(wire_length)
      # Conver to map to be able to merge it
      |> Map.new()
      # Keep the lower distance if we encounter a duplicate
      |> Map.merge(positions, fn _k, v1, v2 -> min(v1, v2) end)

    do_run_wire({new_position, wire_length + distance}, new_positions, tail)
  end

  # Gets the new position tuple
  defp get_new_position({x, y}, "R", distance), do: {x + distance, y}
  defp get_new_position({x, y}, "L", distance), do: {x - distance, y}
  defp get_new_position({x, y}, "U", distance), do: {x, y + distance}
  defp get_new_position({x, y}, "D", distance), do: {x, y - distance}
end
