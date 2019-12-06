defmodule Solution do
  @center "COM"

  # Correct answer: 261306
  def solve1(file \\ "./input.txt") do
    file
    |> read_orbits()
    |> Enum.group_by(fn {parent, _child} -> parent end, fn {_parent, child} -> child end)
    |> build_orbits()
    |> count_orbits()
  end

  # Correct answer: 382
  def solve2(file \\ "./input.txt") do
    raw_orbits = file |> read_orbits()

    mapping_a =
      raw_orbits
      |> Enum.group_by(fn {parent, _child} -> parent end, fn {_parent, child} -> child end)

    mapping_b =
      raw_orbits
      |> Enum.group_by(fn {_parent, child} -> child end, fn {parent, _child} -> parent end)

    orbits = Map.merge(mapping_a, mapping_b, fn _k, v1, v2 -> v1 ++ v2 end)

    find_santa(orbits)
  end

  defp read_orbits(file) do
    file
    |> File.stream!([:trim_bom])
    |> Stream.map(&binary_part(&1, 0, byte_size(&1) - 1))
    |> Stream.map(fn line ->
      [a, b] = String.split(line, ")")
      {a, b}
    end)
  end

  defp build_orbits(orbits) do
    orbit = {@center, Map.fetch!(orbits, @center)}
    {@center, children} = build_orbits(orbits, orbit)

    children
  end

  defp build_orbits(orbits, {parent, children}) do
    children =
      for child <- children do
        build_orbits(orbits, {child, Map.get(orbits, child, [])})
      end

    {parent, children}
  end

  defp count_orbits(orbits) do
    orbits
    |> Enum.flat_map(&count_orbits(&1, 1))
    |> Enum.sum()
  end

  defp count_orbits({_parent, []}, count), do: [count]

  defp count_orbits({_parent, children}, count) do
    [count | Enum.flat_map(children, &count_orbits(&1, count + 1))]
  end

  defp find_santa(orbits) do
    # -1 because YOU is not an actual orbit
    find_santa(nil, "YOU", orbits, -1)
    |> Enum.min()
  end

  # -1 because SAN is not an actual orbit
  defp find_santa(_, "SAN", _, count), do: [count - 1]

  defp find_santa(parent, name, orbits, count) do
    Map.fetch!(orbits, name)
    |> Kernel.--([parent])
    |> Enum.flat_map(&find_santa(name, &1, orbits, count + 1))
  end
end
