
defmodule Poker do

  @moduledoc """
  http://elixirquiz.github.io/2014-09-13-poker-part-3-making-decisions.html

  This is a continuation of the previous weeks quizes
  http://elixirquiz.github.io/2014-08-30-poker-part-1-a-deck-of-cards.html
  http://elixirquiz.github.io/2014-09-06-poker-part-2-finding-a-winner.html
  """

  defmodule Card do
    @type suit :: :clubs | :diamonds | :hearts | :spades
    @type rank :: :ace | :king | :queen | :jack | 1..10
    @type t :: {rank, suit}

    @suits [:clubs, :diamonds, :hearts, :spades]
    @ranks [:ace, :king, :queen, :jack, 10, 9, 8, 7, 6, 5, 4, 3, 2]

    @spec suits() :: [suit]
    def suits, do: @suits

    @spec ranks() :: [rank]
    def ranks, do: @ranks

    @spec parse(String.t) :: t
    def parse("A" <> suit), do: parse(:ace, suit)
    def parse("K" <> suit), do: parse(:king, suit)
    def parse("Q" <> suit), do: parse(:queen, suit)
    def parse("J" <> suit), do: parse(:jack, suit)
    def parse("10" <> suit), do: parse(10, suit)
    def parse("9" <> suit), do: parse(9, suit)
    def parse("8" <> suit), do: parse(8, suit)
    def parse("7" <> suit), do: parse(7, suit)
    def parse("6" <> suit), do: parse(6, suit)
    def parse("5" <> suit), do: parse(5, suit)
    def parse("4" <> suit), do: parse(4, suit)
    def parse("3" <> suit), do: parse(3, suit)
    def parse("2" <> suit), do: parse(2, suit)
    defp parse(rank, "C"), do: {rank, :clubs}
    defp parse(rank, "D"), do: {rank, :diamonds}
    defp parse(rank, "H"), do: {rank, :hearts}
    defp parse(rank, "S"), do: {rank, :spades}

    @spec sorter(t, t) :: boolean
    def sorter({lr, _}, {rr, _}) do
      rank_of(lr) <= rank_of(rr)
    end

    @spec compare(t, t) :: number
    def compare({lr, _}, {rr, _}) do
      rank_of(lr) - rank_of(rr)
    end

    @spec rank_of(rank | t) :: number
    def rank_of({rank, _}), do: rank_of(rank)
    def rank_of(:ace), do: 14
    def rank_of(:king), do: 13
    def rank_of(:queen), do: 12
    def rank_of(:jack), do: 11
    def rank_of(n) when is_integer(n) and n in 1..10, do: n
  end

  defmodule Hand do
    alias Poker.Card

    @type t :: [Poker.Card.t]
    @type kind_of_hand :: :straight_flush |
                          :four_of_a_kind |
                          :full_house |
                          :flush |
                          :straight |
                          :three_of_a_kind |
                          :two_pair |
                          :one_pair |
                          :high_card

    @spec parse([String.t | t]) :: t
    def parse(hand) do
      hand |> Enum.map(fn
        (c) when is_binary(c) -> Card.parse(c)
        (c) -> c
      end)
    end

    @spec winner([{String.t, t} | {String.t, [String.t]}]) :: String.t | {:split, [String.t]}
    def winner([{name, _}]), do: name
    def winner([{n1, h1}, {n2, h2} | hs]) do
      case compare(h1, h2) do
        n when n > 0 -> winner([{n1, h1} | hs])
        n when n < 0 -> winner([{n2, h2} | hs])
        _ ->
          case {n1, n2} do
            {{:split, ns1}, {:split, ns2}} -> winner([{{:split, ns1 ++ ns2}, h1} | hs])
            {{:split, ns1}, _} -> winner([{{:split, [n2 | ns1]}, h1} | hs])
            {_, {:split, ns2}} -> winner([{{:split, [n1 | ns2]}, h1} | hs])
            {_, _} -> winner([{{:split, [n1, n2]}, h1} | hs])
          end
      end
    end

    @spec compare(t, t) :: number
    def compare(h1, h2) do
      rank_of(h1) - rank_of(h2)
    end

    @spec sorter(t, t) :: boolean
    def sorter({lr, _}, {rr, _}) do
      rank_of(lr) <= rank_of(rr)
    end

    @spec rank_of(t | {kind_of_hand, tuple} | binary) :: number
    def rank_of(<<r::size(24)>>), do: r
    def rank_of({_, {r1, r2}}),
      do: rank_of(<<r1::size(4), r2::size(4), 0::size(16)>>)
    def rank_of({_, {r1, r2, r3}}),
      do: rank_of(<<r1::size(4), r2::size(4), r3::size(4), 0::size(12)>>)
    def rank_of({_, {r1, r2, r3, r4}}),
      do: rank_of(<<r1::size(4), r2::size(4), r3::size(4), r4::size(4), 0::size(8)>>)
    def rank_of({_, {r1, r2, r3, r4, r5}}),
      do: rank_of(<<r1::size(4), r2::size(4), r3::size(4), r4::size(4), r5::size(4), 0::size(4)>>)
    def rank_of({_, {r1, r2, r3, r4, r5, r6}}),
      do: rank_of(<<r1::size(4), r2::size(4), r3::size(4), r4::size(4), r5::size(4), r6::size(4)>>)
    def rank_of(hand), do: rank_of(identify(hand))

    @spec identify(t) :: {kind_of_hand, rank::tuple}
    def identify(hand) do
      [hand]
        |> Enum.map(&parse/1)
        |> Enum.flat_map(fn(hand) -> [hand, hand |> aces_as_ones] end)
        |> Enum.map(fn(hand) ->
              hand
              |> Enum.sort(&Card.sorter/2)
              |> Enum.map(fn(c = {_, s}) -> {Card.rank_of(c), s} end)
              |> do_identify
            end)
        |> Enum.sort_by(&rank_of/1)
        |> List.last
    end

    defp aces_as_ones(hand) do
      hand |> Enum.map(fn {:ace, s} -> {1, s};  c  -> c end)
    end

    defp do_identify([{r1, s}, {r2, s}, {r3, s}, {r4, s}, {r5, s}])
      when [r2 - r1, r3 - r2, r4 - r3, r5 - r4] == [1, 1, 1, 1], do: {:straight_flush, {9, r5}}

    defp do_identify([{r1, _}, {r1, _}, {r1, _}, {r1, _}, {r2, _}]), do: {:four_of_a_kind, {8, r1, r2}}
    defp do_identify([{r1, _}, {r2, _}, {r2, _}, {r2, _}, {r2, _}]), do: {:four_of_a_kind, {8, r2, r1}}

    defp do_identify([{r1, _}, {r1, _}, {r1, _}, {r2, _}, {r2, _}]), do: {:full_house, {7, r1, r2}}
    defp do_identify([{r2, _}, {r2, _}, {r1, _}, {r1, _}, {r1, _}]), do: {:full_house, {7, r1, r2}}

    defp do_identify([{_, s}, {_, s}, {_, s}, {_, s}, {r5, s}]), do: {:flush, {6, r5}}

    defp do_identify([{r1, _}, {r2, _}, {r3, _}, {r4, _}, {r5, _}])
      when [r2 - r1, r3 - r2, r4 - r3, r5 - r4] == [1, 1, 1, 1], do: {:straight, {5, r5}}

    defp do_identify([{r1, _}, {r1, _}, {r1, _}, {_, _}, {_, _}]), do: {:three_of_a_kind, {4, r1}}
    defp do_identify([{_, _}, {r2, _}, {r2, _}, {r2, _}, {_, _}]), do: {:three_of_a_kind, {4, r2}}
    defp do_identify([{_, _}, {_, _}, {r3, _}, {r3, _}, {r3, _}]), do: {:three_of_a_kind, {4, r3}}

    defp do_identify([{r1, _}, {r1, _}, {r2, _}, {r2, _}, {r3, _}]), do: {:two_pair, {3, r2, r1, r3}}
    defp do_identify([{r1, _}, {r2, _}, {r2, _}, {r3, _}, {r3, _}]), do: {:two_pair, {3, r3, r2, r1}}
    defp do_identify([{r1, _}, {r1, _}, {r2, _}, {r3, _}, {r3, _}]), do: {:two_pair, {3, r3, r1, r2}}

    defp do_identify([{r1, _}, {r1, _}, {_, _}, {_, _}, {r4, _}]), do: {:one_pair, {2, r1, r4}}
    defp do_identify([{_, _}, {r2, _}, {r2, _}, {_, _}, {r4, _}]), do: {:one_pair, {2, r2, r4}}
    defp do_identify([{_, _}, {_, _}, {r3, _}, {r3, _}, {r4, _}]), do: {:one_pair, {2, r3, r4}}
    defp do_identify([{_, _}, {_, _}, {r3, _}, {r4, _}, {r4, _}]), do: {:one_pair, {2, r4, r3}}

    defp do_identify([{r1, _}, {r2, _}, {r3, _}, {r4, _}, {r5, _}]), do: {:high_card, {1, r5, r4, r3, r2, r1}}
  end

  defmodule Deck do
    alias Poker.Card, as: Card

    @type t :: [Card.t]

    @cards for rank <- Card.ranks, suit <- Card.suits, do: {rank, suit}

    @spec new() :: t
    def new do
      @cards
    end

    @spec shuffle(t) :: t
    def shuffle(deck, seed \\ :os.timestamp) do
      :random.seed(seed)
      Enum.shuffle(deck)
    end

    @spec deal_to(t, number) :: [Hand.t]
    def deal_to(deck, number_of_players) when number_of_players in 2..6 do
      # Cards are traditionally dealt to players in turn, one at a time,
      # such that no player has 2 cards until each person has 1
      shuffle(deck)
        |> Enum.chunk(number_of_players)
        |> Enum.take(5)
        |> List.unzip
    end
  end
end


ExUnit.start

defmodule PokerTest do
  use ExUnit.Case, async: true

  alias Poker.Deck
  alias Poker.Hand

end
