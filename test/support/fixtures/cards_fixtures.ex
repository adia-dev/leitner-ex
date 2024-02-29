defmodule Leitner.CardsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Leitner.Cards` context.
  """

  @doc """
  Generate a card.
  """
  def card_fixture(attrs \\ %{}) do
    {:ok, card} =
      attrs
      |> Enum.into(%{
        answer: "some answer",
        category: :first,
        question: "some question",
        tag: "some tag"
      })
      |> Leitner.Cards.create_card()

    card
  end
end
