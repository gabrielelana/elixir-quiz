
defmodule RunLength do

  @moduledoc """
  http://elixirquiz.github.io/2014-08-16-run-length-encoding.html
  """

  @doc """
  Given a string of uppercase characters in the range A-Z, replace runs of
  sequential characters with a single instance of that value preceded by the
  number of items in the run.

  ## Example

      iex> RunLength.encode("JJJTTWPPMMMMYYYYYYYYYVVVVVV")
      3J2T1W2P4M9Y6V
  """
  @spec encode(String.t) :: String.t
  def encode(string) do
    String.graphemes(string)
      |> Enum.reduce([], fn
          (c, [{c, n} | runs]) -> [{c, n+1}|runs]
          (c, runs) -> [{c, 1}|runs]
        end)
      |> Enum.map(fn {c, n} -> "#{n}#{c}" end)
      |> Enum.reverse
      |> Enum.join
  end

  def encode_using_regex(string) do
    Regex.scan(~r/([A-Z])\1*/, string)
      |> Enum.map(fn([run, c]) -> "#{String.length(run)}#{c}" end)
      |> Enum.join
  end
end

ExUnit.start

defmodule RunLengthTest do
  use ExUnit.Case, async: true

  test "encode/1" do
    assert RunLength.encode("") == ""
    assert RunLength.encode("J") == "1J"
    assert RunLength.encode("JJ") == "2J"
    assert RunLength.encode("JJK") == "2J1K"
    assert RunLength.encode("JJJTTWPPMMMMYYYYYYYYYVVVVVV") == "3J2T1W2P4M9Y6V"
  end
end
