defmodule LeitnerWeb.CardJSON do
  alias Leitner.Cards.Card

  @doc """
  Renders a list of cards.
  """
  def index(%{cards: cards}) do
    cards
    |> Enum.map(&data(&1))
  end

  @doc """
  Renders a single card.
  """
  def show(%{card: card}) do
    data(card)
  end

  defp data(%Card{} = card) do
    %{
      id: card.id,
      tag: card.tag,
      category: Atom.to_string(card.category) |> String.upcase(),
      question: card.question,
      answer: card.answer
    }
  end
end
