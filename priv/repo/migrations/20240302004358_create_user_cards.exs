defmodule Leitner.Repo.Migrations.CreateUserCards do
  use Ecto.Migration

  def change do
    create table(:user_cards, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :user_id, references(:users, on_delete: :delete_all, type: :binary_id), null: false
      add :card_id, references(:cards, on_delete: :delete_all, type: :binary_id), null: false
      add :last_review_at, :naive_datetime
      add :next_review_at, :naive_datetime

      timestamps()
    end

    create unique_index(:user_cards, [:card_id, :user_id])
    create index(:user_cards, [:user_id])
    create index(:user_cards, [:card_id])
    create index(:user_cards, [:last_review_at])
    create index(:user_cards, [:next_review_at])
  end
end
