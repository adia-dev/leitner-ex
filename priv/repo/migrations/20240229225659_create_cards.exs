defmodule Leitner.Repo.Migrations.CreateCards do
  use Ecto.Migration

  def change do
    create table(:cards, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :category, :string
      add :question, :string
      add :answer, :string
      add :tag, :string

      timestamps(type: :utc_datetime)
    end
  end
end
