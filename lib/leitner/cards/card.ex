defmodule Leitner.Cards.Card do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "cards" do
    field :tag, :string
    field :category, Ecto.Enum, values: [:first, :second, :third, :fourth, :fifth, :sixth, :seventh, :done]
    field :question, :string
    field :answer, :string

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(card, attrs) do
    card
    |> cast(attrs, [:category, :question, :answer, :tag])
    |> validate_required([:category, :question, :answer, :tag])
  end
end
