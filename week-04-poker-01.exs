
defmodule Poker do

  @moduledoc """
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

    @spec rank_of(rank) :: number
    defp rank_of(:ace), do: 14
    defp rank_of(:king), do: 13
    defp rank_of(:queen), do: 12
    defp rank_of(:jack), do: 11
    defp rank_of(n) when is_integer(n) and n in 1..10, do: n
  end

  defmodule Deck do
    alias Poker.Card, as: Card

    @type t :: list(Card.t)

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
  end
end


ExUnit.start

defmodule PokerTest do
  use ExUnit.Case, async: true

  test "Poker.Card.compare/2 compares two cards" do
    assert Poker.Card.compare({:ace, :clubs}, {10, :spades}) > 0
    assert Poker.Card.compare({:ace, :clubs}, {:ace, :spades}) == 0
    assert Poker.Card.compare({:queen, :clubs}, {:ace, :spades}) < 0
    assert Poker.Card.compare({:ace, :clubs}, {1, :clubs}) > 0
  end

  test "Poker.Deck.new/0 creates a deck of cards" do
    deck = Poker.Deck.new
    assert deck == [
      {:ace, :clubs}, {:ace, :diamonds}, {:ace, :hearts}, {:ace, :spades},
      {:king, :clubs}, {:king, :diamonds}, {:king, :hearts}, {:king, :spades},
      {:queen, :clubs}, {:queen, :diamonds}, {:queen, :hearts}, {:queen, :spades},
      {:jack, :clubs}, {:jack, :diamonds}, {:jack, :hearts}, {:jack, :spades},
      {10, :clubs}, {10, :diamonds}, {10, :hearts}, {10, :spades},
      {9, :clubs}, {9, :diamonds}, {9, :hearts}, {9, :spades},
      {8, :clubs}, {8, :diamonds}, {8, :hearts}, {8, :spades},
      {7, :clubs}, {7, :diamonds}, {7, :hearts}, {7, :spades},
      {6, :clubs}, {6, :diamonds}, {6, :hearts}, {6, :spades},
      {5, :clubs}, {5, :diamonds}, {5, :hearts}, {5, :spades},
      {4, :clubs}, {4, :diamonds}, {4, :hearts}, {4, :spades},
      {3, :clubs}, {3, :diamonds}, {3, :hearts}, {3, :spades},
      {2, :clubs}, {2, :diamonds}, {2, :hearts}, {2, :spades}
    ]
  end

  test "Poker.Deck.shuffle/1 shuffles a deck of cards" do
    seed = :os.timestamp
    deck = Poker.Deck.new
    assert Poker.Deck.shuffle(deck, seed) != deck
    assert Poker.Deck.shuffle(deck, seed) == Poker.Deck.shuffle(deck, seed)
  end
end
