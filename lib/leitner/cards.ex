defmodule Leitner.Cards do
  @moduledoc """
  The Cards context.
  """

  import Ecto.Query, warn: false
  alias Leitner.Repo

  alias Leitner.Cards.Card

  @doc """
  Returns the list of cards.

  ## Examples

      iex> list_cards()
      [%Card{}, ...]

  """
  def list_cards do
    Repo.all(Card)
  end

  @doc """
  Gets a single card.

  Raises `Ecto.NoResultsError` if the Card does not exist.

  ## Examples

      iex> get_card!(123)
      %Card{}

      iex> get_card!(456)
      ** (Ecto.NoResultsError)

  """
  def get_card!(id), do: Repo.get!(Card, id)

  @doc """
  Creates a card.

  ## Examples

      iex> create_card(%{field: value})
      {:ok, %Card{}}

      iex> create_card(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_card(attrs \\ %{}) do
    %Card{}
    |> Card.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a card.

  ## Examples

      iex> update_card(card, %{field: new_value})
      {:ok, %Card{}}

      iex> update_card(card, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_card(%Card{} = card, attrs) do
    card
    |> Card.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Answer a card.

  ## Options

    * `:reveal` - Return the good answer, this option can be set to `false`.
      Defaults to `true`.

    * `:distance_threshold` - Validate the answer based on the distance between the guess
      and the expected answer, this option can be set to `1.0` for exact match.
      Defaults to `0.8`.
      Value must be between `0.0` and `1.0`

  ## Examples

      # The card will be updated to the next category
      iex> answer_card(card, %{guess: "good_answer"}, opts)
      {:ok, %Card{}, category}

      iex> update_card(card, %{guess: "bad_answer"})
      # The card has been updated to the next category
      {:error, "wrong answer", maybe_good_answer, :first}

  """
  def answer_card(%Card{} = card, attrs, opts \\ [reveal: false, distance_threshold: 0.8])
      when card.category === :done,
      do: {:error, "This card has already been mastered"}

  def answer_card(%Card{} = card, attrs, opts) do
    {:ok, next_category} = Card.next_category(card)
    dbg(next_category)

    case Map.get(attrs, :guess) do
      nil ->
        {:error, "Missing mandatory field :guess.", card.category}

      answer ->
        if String.jaro_distance(card.answer, attrs.guess) >= opts[:distance_threshold] do
          card
          |> Card.changeset(%{category: next_category})
          |> Repo.update()

          {:ok, "good answer", card.answer, next_category}
        else
          card
          |> Card.changeset(%{category: next_category})
          |> Repo.update()

          {:error, "wrong answer", card.answer, :first}
        end
    end
  end

  @doc """
  Deletes a card.
  ## Examples

      iex> delete_card(card)
      {:ok, %Card{}}

      iex> delete_card(card)
      {:error, %Ecto.Changeset{}}

  """
  def delete_card(%Card{} = card) do
    Repo.delete(card)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking card changes.

  ## Examples

      iex> change_card(card)
      %Ecto.Changeset{data: %Card{}}

  """
  def change_card(%Card{} = card, attrs \\ %{}) do
    Card.changeset(card, attrs)
  end
end
