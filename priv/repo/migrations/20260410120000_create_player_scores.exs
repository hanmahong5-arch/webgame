defmodule LurusWww.Repo.Migrations.CreatePlayerScores do
  use Ecto.Migration

  def change do
    create table(:player_scores) do
      add :player_name, :string, null: false
      add :best_score, :integer, default: 0
      add :total_score, :integer, default: 0
      add :total_kills, :integer, default: 0
      add :games_played, :integer, default: 0
      add :last_played_at, :utc_datetime

      timestamps(type: :utc_datetime)
    end

    create unique_index(:player_scores, [:player_name])
    create index(:player_scores, [:total_score])
    create index(:player_scores, [:last_played_at])
  end
end
