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
      answer: card.answer,
      next_answer_date: card.next_answer_date,
      last_answered: card.last_answered,
    }
  end
end
