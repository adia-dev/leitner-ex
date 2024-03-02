defmodule Leitner.Cards do
  @moduledoc """
  The Cards context.
  """

  import Ecto.Query, warn: false
  alias Leitner.Repo

  alias Leitner.Cards.Card

  @categories [:first, :second, :third, :fourth, :fifth, :sixth, :seventh, :done]

  @doc """
  Returns the list of cards.

  ## Examples

      iex> list_cards()
      [%Card{}, ...]

  """
  def list_cards do
    Repo.all(Card)
  end

  def list_cards_by_category do
    query =
      from c in Card,
        order_by: [desc: c.category]

    Repo.all(query)
  end

  def list_cards_by_tags(tags) when not is_list(tags), do: []

  def list_cards_by_tags(tags) do
    query =
      from c in Card,
        where: c.tag in ^tags

    Repo.all(query)
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
  Gets a single card.

  Returns a record of nil if not found

  ## Examples

      iex> get_card!(123)
      {:ok, %Card{}}

      iex> get_card!(456)
      nil

  """
  def get_card(id), do: Repo.get(Card, id)

  @doc """
  Creates a card.

  ## Examples

      iex> create_card(%{field: value})
      %Card{}

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
    next_category = Card.next_category(card.category)

    case Map.get(attrs, :guess) do
      nil ->
        {:error, :missing_mandatory_field_guess}

      guess ->
        if String.jaro_distance(card.answer, guess) >= opts[:distance_threshold] do
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

  def add_card_to_user(user_id, card_id) do
    %Leitner.User.Cards.UserCard{}
    |> Leitner.User.Cards.UserCard.changeset(%{user_id: user_id, card_id: card_id})
    |> Leitner.Repo.insert()
  end

  def update_card_review(user_id, card_id, correct) do
    query =
      from uc in Leitner.User.Cards.UserCard,
        where: uc.user_id == ^user_id and uc.card_id == ^card_id,
        preload: [:user, :card]

    Repo.one(query)
    |> case do
      nil ->
        {:error, :not_found}

      %Leitner.User.Cards.UserCard{} = user_card ->
        new_category = determine_new_category(user_card.card.category, correct)
        next_review_at = determine_next_review_date(determine_category_index(new_category))

        changes = %{
          category: new_category,
          last_review_at: DateTime.utc_now(),
          next_review_at: next_review_at
        }

        user_card
        |> Leitner.User.Cards.UserCard.changeset(changes)
        |> Leitner.Repo.update()
    end
  end

  defp determine_new_category(current_category, true) do
    case current_category do
      :done ->
        :done

      _ ->
        current = Enum.find_index(@categories, &(&1 == current_category))
        Enum.at(@categories, current + 1)
    end
  end

  defp determine_new_category(_, false), do: :first

  defp determine_category_index(category), do: Enum.find_index(@categories, &(&1 == category))

  defp determine_next_review_date(category) do
    DateTime.add(
      DateTime.utc_now(),
      Enum.reduce(0..(category + 1), 0, fn _, acc -> acc * 2 end),
      :day
    )
  end

  def remove_mastered_card(user_card_id) do
    user_card_id
    |> Leitner.Repo.get!(Leitner.User.Cards.UserCard)
    |> Leitner.Repo.delete()
  end

  def list_user_cards(user_id) do
    query =
      from uc in Leitner.User.Cards.UserCard,
        where: uc.user_id == ^user_id,
        preload: [:card]

    Leitner.Repo.all(query)
  end

  def list_cards_for_review(user_id) do
    query =
      from uc in Leitner.User.Cards.UserCard,
        where: uc.user_id == ^user_id,
        where: uc.next_review_at <= ^DateTime.utc_now(),
        preload: [:card]

    Leitner.Repo.all(query)
  end
end
