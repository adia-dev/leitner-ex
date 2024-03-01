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
      Defaults to `0.97`.
      Value must be between `0.0` and `1.0`

  ## Examples

      # The card will be updated to the next category
      iex> answer_card(card, %{guess: "good_answer"}, opts)
      {:ok, %Card{}, category}

      iex> update_card(card, %{guess: "bad_answer"})
      {:error, "wrong answer", maybe_good_answer}

      iex> update_card(card, %{answer: "bad_answer"})
      {:error, "Missing mandatory field :guess."}

  """
  def answer_card(%Card{} = card, attrs, opts \\ [reveal: false, distance_threshold: 0.97])
      when card.category === :done,
      do: {:error, :already_mastered}

  def answer_card(%Card{} = card, attrs, opts) do
    {:ok, next_category} = Card.next_category(card)

    case Map.get(attrs, :guess) do
      nil ->
        {:error, :missing_mandatory_field_guess}

      answer ->
        if String.jaro_distance(card.answer, attrs.guess) >= opts[:distance_threshold] do
          case update_card(card, %{category: next_category}) do
            {:ok, updated_card} ->
              {:ok, updated_card}

            error ->
              error
          end
        else
          case update_card(card, %{category: :first}) do
            {:ok, updated_card} ->
              maybe_good_answer = if opts[:reveal], do: card.answer, else: nil
              {:error, :wrong_answer, updated_card}

            error ->
              error
          end
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
