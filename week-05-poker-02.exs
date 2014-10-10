
defmodule Poker do

  @moduledoc """
  http://elixirquiz.github.io/2014-09-06-poker-part-2-finding-a-winner.html

  This is a continuation of the previous week quiz
  http://elixirquiz.github.io/2014-08-30-poker-part-1-a-deck-of-cards.html
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
    def parse("1" <> suit), do: parse(1, suit)
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

    @spec parse([String.t | t]) :: t
    def parse(hand) do
      hand |> Enum.map(fn
        (c) when is_binary(c) -> Card.parse(c)
        (c) -> c
      end)
    end

    @spec identify(t) :: atom
    def identify(hand) do
      hand = hand |> parse |> Enum.sort(&Card.sorter/2)
      cond do
        straight?(hand) and flush?(hand) -> :straight_flush
        four_of_a_kind?(hand) -> :four_of_a_kind
        full_house?(hand) -> :full_house
        flush?(hand) -> :flush
        straight?(hand) -> :straight
        three_of_a_kind?(hand) -> :three_of_a_kind
        two_pair?(hand) -> :two_pair
        one_pair?(hand) -> :one_pair
        true -> :high_card
      end
    end

    defp four_of_a_kind?([{r, _}, {r, _}, {r, _}, {r, _}, {_, _}]), do: true
    defp four_of_a_kind?([{_, _}, {r, _}, {r, _}, {r, _}, {r, _}]), do: true
    defp four_of_a_kind?(_), do: false

    defp full_house?([{r1, _}, {r1, _}, {r1, _}, {r2, _}, {r2, _}]), do: true
    defp full_house?([{r2, _}, {r2, _}, {r1, _}, {r1, _}, {r1, _}]), do: true
    defp full_house?(_), do: false

    defp three_of_a_kind?([{r, _}, {r, _}, {r, _}, {_, _}, {_, _}]), do: true
    defp three_of_a_kind?([{_, _}, {r, _}, {r, _}, {r, _}, {_, _}]), do: true
    defp three_of_a_kind?([{_, _}, {_, _}, {r, _}, {r, _}, {r, _}]), do: true
    defp three_of_a_kind?(_), do: false

    defp two_pair?([{r1, _}, {r1, _}, {r2, _}, {r2, _}, {_, _}]), do: true
    defp two_pair?([{_, _}, {r1, _}, {r1, _}, {r2, _}, {r2, _}]), do: true
    defp two_pair?([{r1, _}, {r1, _}, {_, _}, {r2, _}, {r2, _}]), do: true
    defp two_pair?(_), do: false

    defp one_pair?([{r, _}, {r, _}, {_, _}, {_, _}, {_, _}]), do: true
    defp one_pair?([{_, _}, {r, _}, {r, _}, {_, _}, {_, _}]), do: true
    defp one_pair?([{_, _}, {_, _}, {r, _}, {r, _}, {_, _}]), do: true
    defp one_pair?([{_, _}, {_, _}, {_, _}, {r, _}, {r, _}]), do: true
    defp one_pair?(_), do: false

    defp straight?(hand) do
      hand
        |> Enum.chunk(2, 1)
        |> Enum.map(fn([c1, c2]) -> Card.rank_of(c2) - Card.rank_of(c1) end)
        == [1,1,1,1]
    end

    defp flush?([{_, s}, {_, s}, {_, s}, {_, s}, {_, s}]), do: true
    defp flush?(_), do: false
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

  test "Deck.deal_hands_to/1 deal hands of cards to a number of players" do
    deck = Deck.new
    [h1, h2] = Deck.deal_to(deck, 2)
    assert length(h1) == 5
    assert length(h2) == 5
    assert Set.intersection(Enum.into(h1, HashSet.new), Enum.into(h2, HashSet.new)) == HashSet.new
  end

  test "identify a straight flush" do
    assert Hand.identify(~w{2S 3S 4S 5S 6S}) == :straight_flush
    assert Hand.identify(~w{6S 5S 4S 2S 3S}) == :straight_flush
    assert Hand.identify(~w{1S 2S 3S 4S 5S}) == :straight_flush
    assert Hand.identify(~w{AS KS QS JS 10S}) == :straight_flush
  end

  test "identify a flush" do
    assert Hand.identify(~w{2S 4S 6S 7S 8S}) == :flush
  end

  test "Hand.identify/1 can identify a straight" do
    assert Hand.identify(~w{2S 3D 4S 5S 6S}) == :straight
  end

  test "identify four of a kind" do
    assert Hand.identify(~w{1S 1D 1C 1H 6S}) == :four_of_a_kind
    assert Hand.identify(~w{6S 1D 1C 1H 1S}) == :four_of_a_kind
    assert Hand.identify(~w{QS QD QC QH 1S}) == :four_of_a_kind
    assert Hand.identify(~w{QS 1D QC QH QD}) == :four_of_a_kind
  end

  test "identify three of a kind" do
    assert Hand.identify(~w{1S 1D 1C 4H 6S}) == :three_of_a_kind
    assert Hand.identify(~w{1S 2D 2C 2H 6S}) == :three_of_a_kind
    assert Hand.identify(~w{1S 2D 3C 3H 3S}) == :three_of_a_kind
  end

  test "identify one pair" do
    assert Hand.identify(~w{1S 1D 2C 3H 6S}) == :one_pair
    assert Hand.identify(~w{1C 2S 2D 3H 6S}) == :one_pair
    assert Hand.identify(~w{1C 2S 3D 3H 6S}) == :one_pair
    assert Hand.identify(~w{1C 2S 3D 6H 6S}) == :one_pair
  end

  test "identify two pair" do
    assert Hand.identify(~w{1S 1D 2C 2H 6S}) == :two_pair
    assert Hand.identify(~w{1S 1D 2C 3H 3S}) == :two_pair
    assert Hand.identify(~w{1S 2D 2C 3H 3S}) == :two_pair
  end

  test "identify full house" do
    assert Hand.identify(~w{1S 1D 2C 2H 2S}) == :full_house
    assert Hand.identify(~w{2S 2D 2C 1H 1S}) == :full_house
  end

  test "Hand.identify/1 can identify high card" do
    assert Hand.identify(~w{1S 3D 5C QH 8S}) == :high_card
  end

  test "Deck.winner/1 determines the winner in a list of hands" do

  end
end
