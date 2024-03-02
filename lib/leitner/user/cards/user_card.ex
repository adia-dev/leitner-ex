defmodule Leitner.User.Cards.UserCard do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "user_cards" do
    belongs_to :user, Leitner.Accounts.User, type: :binary_id, references: :id
    belongs_to :card, Leitner.Cards.Card, type: :binary_id, references: :id

    field :last_review_at, :naive_datetime
    field :next_review_at, :naive_datetime

    timestamps()
  end

    @doc false
  def changeset(user_card, attrs) do
    user_card
    |> cast(attrs, [:user_id, :card_id, :last_review_at, :next_review_at])
    |> validate_required([:user_id, :card_id])
  end
end
