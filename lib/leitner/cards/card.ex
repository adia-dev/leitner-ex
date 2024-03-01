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

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(card, attrs) do
    card
    |> cast(attrs, [:category, :question, :answer, :tag])
    |> validate_required([:question, :answer])
  end

  def next_category(%Leitner.Cards.Card{category: category} = _card) do
    case category do
      :done ->
        :done

      _ ->
        current = Enum.find_index(@categories, &(&1 == category))
        Enum.at(@categories, current + 1)
    end
  end
end
