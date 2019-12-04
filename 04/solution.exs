defmodule Solution do
  # Correct answer: 895
  def solve1(input \\ "./input.txt") do
    input
    |> get_sequence()
    |> Enum.count(&(&1 |> Integer.to_string() |> verify_number()))
  end

  # Correct answer: 591
  def solve2(input \\ "./input.txt") do
    input
    |> get_sequence()
    |> Enum.count(&(&1 |> Integer.to_string() |> verify_number2()))
  end

  defp get_sequence(file) do
    [min, max] =
      file
      |> File.read!()
      |> String.trim_trailing("\n")
      |> String.split("-")
      |> Enum.map(&String.to_integer/1)

    min..max
  end

  defp verify_number(number, last_digit \\ ?0, double? \\ false)

  # If we are done and encountered a double (or more), the number is correct
  defp verify_number(<<>>, _last_digit, double?), do: double?

  # Decreasing pair of digits
  defp verify_number(<<digit::utf8, _::binary>>, last_digit, _double?)
       when digit < last_digit do
    false
  end

  defp verify_number(<<digit::utf8, rest::binary>>, last_digit, double?) do
    verify_number(rest, digit, double? or digit == last_digit)
  end

  defp verify_number2(number, last_digit \\ ?0, counts \\ Map.new())

  # If we are done and encountered a double (not triple or even more), the number is correct
  defp verify_number2(<<>>, _last_digit, counts) do
    counts
    |> Map.values()
    |> Enum.member?(2)
  end

  # Decreasing pair of digits
  defp verify_number2(<<digit::utf8, _::binary>>, last_digit, _counts)
       when digit < last_digit do
    false
  end

  defp verify_number2(<<digit::utf8, rest::binary>>, _last_digit, counts) do
    counts = Map.update(counts, digit, 1, &(&1 + 1))
    verify_number2(rest, digit, counts)
  end
end
