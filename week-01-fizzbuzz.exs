
defmodule FizzBuzz do

  @moduledoc """
  http://elixirquiz.github.io/2014-08-11-fizzbuzz.html
  """

  @doc """
  Print the numbers from 1 to 100, replacing multiples of 3 with the word Fizz
  and multiples of 5 with the word Buzz. For numbers that are divisible by 3
  and 5, replace the number with the word FizzBuzz.

  ## Example

      iex> FizzBuzz.upto 20
      1 2 Fizz 4 Buzz Fizz 7 8 Fizz Buzz 11 Fizz 13 14 FizzBuzz
  """
  @spec upto(number) :: String.t
  def upto(n) do
    stream |> Enum.take(n) |> Enum.join(" ")
  end

  defp stream do
    fizz = Stream.cycle [nil, nil, "Fizz"]
    buzz = Stream.cycle [nil, nil, nil, nil, "Buzz"]
    Stream.zip(fizz, buzz) |> Stream.with_index |> Stream.map(&speak/1)
  end

  defp speak({{nil, nil}, n}), do: "#{n+1}"
  defp speak({{fizz, buzz}, _}), do: "#{fizz}#{buzz}"
end


ExUnit.start

defmodule FizzBuzzTest do
  use ExUnit.Case, async: true

  test "upto Fizz" do
    assert FizzBuzz.upto(3) == "1 2 Fizz"
  end

  test "upto Buzz" do
    assert FizzBuzz.upto(5) == "1 2 Fizz 4 Buzz"
  end

  test "upto FizzBuzz" do
    assert FizzBuzz.upto(15) == "1 2 Fizz 4 Buzz Fizz 7 8 Fizz Buzz 11 Fizz 13 14 FizzBuzz"
  end
end
