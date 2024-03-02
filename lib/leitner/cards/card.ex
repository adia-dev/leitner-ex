defmodule Leitner.Cards.Card do
  use Ecto.Schema
  import Ecto.Changeset

  @categories [:first, :second, :third, :fourth, :fifth, :sixth, :seventh, :done]

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "cards" do
    field :tag, :string

    field :category, Ecto.Enum,
      values: [:first, :second, :third, :fourth, :fifth, :sixth, :seventh, :done]

    field :question, :string
    field :answer, :string

    many_to_many :users, Leitner.Accounts.User, join_through: "user_cards"

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(card, attrs) do
    card
    |> cast(attrs, [:category, :question, :answer, :tag])
    |> validate_required([:question, :answer])
  end

  def next_category(:done), do: :done

  def next_category(category) when is_atom(category) do
    current = Enum.find_index(@categories, &(&1 == category))
    Enum.at(@categories, current + 1)
  end

  def next_category(category) do
    category
    |> String.downcase()
    |> String.to_atom()
    |> next_category()
  end
end
