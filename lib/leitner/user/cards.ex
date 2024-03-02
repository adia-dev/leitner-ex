defmodule Leitner.User.Cards do
  @moduledoc """
  The User.Cards context.
  """

  import Ecto.Query, warn: false
  alias Leitner.Repo

  alias Leitner.User.Cards.UserCard

  @doc """
  Returns the list of user_cards.

  ## Examples

      iex> list_user_cards()
      [%UserCard{}, ...]

  """
  def list_user_cards do
    Repo.all(UserCard)
  end

  @doc """
  Gets a single user_card.

  Raises `Ecto.NoResultsError` if the User card does not exist.

  ## Examples

      iex> get_user_card!(123)
      %UserCard{}

      iex> get_user_card!(456)
      ** (Ecto.NoResultsError)

  """
  def get_user_card!(id), do: Repo.get!(UserCard, id)

  @doc """
  Creates a user_card.

  ## Examples

      iex> create_user_card(%{field: value})
      {:ok, %UserCard{}}

      iex> create_user_card(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_user_card(attrs \\ %{}) do
    %UserCard{}
    |> UserCard.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a user_card.

  ## Examples

      iex> update_user_card(user_card, %{field: new_value})
      {:ok, %UserCard{}}

      iex> update_user_card(user_card, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_user_card(%UserCard{} = user_card, attrs) do
    user_card
    |> UserCard.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a user_card.

  ## Examples

      iex> delete_user_card(user_card)
      {:ok, %UserCard{}}

      iex> delete_user_card(user_card)
      {:error, %Ecto.Changeset{}}

  """
  def delete_user_card(%UserCard{} = user_card) do
    Repo.delete(user_card)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking user_card changes.

  ## Examples

      iex> change_user_card(user_card)
      %Ecto.Changeset{data: %UserCard{}}

  """
  def change_user_card(%UserCard{} = user_card, attrs \\ %{}) do
    UserCard.changeset(user_card, attrs)
  end
end
