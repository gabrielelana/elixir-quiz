
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
    import Poker.Card, only: [sorter: 2, rank_of: 1]

    @type t :: [Poker.Card.t]

    def identify(hand) do
      hand |> Enum.sort(&sorter/2) |> identify(:sorted)
    end

    defp identify(hand = [_, _, _, _, {highest_rank, _}], :sorted) do
      cond do
        straight?(hand) and flush?(hand) -> {:straight_flush, highest_rank}
        straight?(hand) -> {:straight, highest_rank}
        flush?(hand) -> {:flush, highest_rank}
      end
    end

    defp straight?(hand) do
      hand
        |> Enum.chunk(2, 1)
        |> Enum.map(fn([c1, c2]) -> rank_of(c2) - rank_of(c1) end)
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

  test "Hand.identify/1 can idenity a straight flush" do
    assert Hand.identify([{2, :spades}, {3, :spades}, {4, :spades}, {5, :spades}, {6, :spades}]) ==
      {:straight_flush, 6}
    assert Hand.identify([{6, :spades}, {5, :spades}, {4, :spades}, {2, :spades}, {3, :spades}]) ==
      {:straight_flush, 6}
    assert Hand.identify([{1, :spades}, {2, :spades}, {3, :spades}, {4, :spades}, {5, :spades}]) ==
      {:straight_flush, 5}
    assert Hand.identify([{:ace, :spades}, {:king, :spades}, {:queen, :spades}, {:jack, :spades}, {10, :spades}]) ==
      {:straight_flush, :ace}
  end

  test "Hand.identify/1 can idenity a flush" do
    assert Hand.identify([{2, :spades}, {4, :spades}, {6, :spades}, {7, :spades}, {8, :spades}]) ==
      {:flush, 8}
  end

  test "Hand.identify/1 can idenity a straight" do
    assert Hand.identify([{2, :spades}, {3, :diamonds}, {4, :spades}, {5, :spades}, {6, :spades}]) ==
      {:straight, 6}
  end

  test "Deck.winner/1 determines the winner in a list of hands" do

  end
end
