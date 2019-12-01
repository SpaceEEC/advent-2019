defmodule Solution do
  # Correct solution: 3452245
  def solve1(file \\ "./input.txt") do
    file
    |> stream_masses()
    |> Stream.map(&needed_fuel/1)
    |> Enum.sum()
  end

  # Generates an a sequence enumerating all masses in the given file.
  defp stream_masses(file) do
    file
    |> File.stream!([:trim_bom])
    # Tream trailing linebreak
    |> Stream.map(&binary_part(&1, 0, byte_size(&1) - 1))
    # Conver to integer
    |> Stream.map(&String.to_integer/1)
  end

  # Calculates the needed fuel for the given mass.
  defp needed_fuel(mass) do
    mass
    |> Kernel./(3)
    |> Kernel.trunc()
    |> Kernel.-(2)
  end

  # Correct solution: 5175499
  def solve2(file \\ "./input.txt") do
    file
    |> stream_masses()
    |> Stream.map(&needed_fuel2/1)
    |> Enum.sum()
  end

  # Calculates the needed fuel for the given mass, the fuel for the fuel,
  # its fuel, etc, until a 0 or negative amount of fuel is encountered.
  defp needed_fuel2(mass, acc \\ 0) do
    needed = needed_fuel(mass)

    if needed > 0 do
      needed_fuel2(needed, acc + needed)
    else
      acc
    end
  end
end
