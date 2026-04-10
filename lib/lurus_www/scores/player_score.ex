defmodule LurusWww.Scores.PlayerScore do
  use Ecto.Schema
  import Ecto.Changeset

  schema "player_scores" do
    field :player_name, :string
    field :best_score, :integer, default: 0
    field :total_score, :integer, default: 0
    field :total_kills, :integer, default: 0
    field :games_played, :integer, default: 0
    field :last_played_at, :utc_datetime

    timestamps(type: :utc_datetime)
  end

  def changeset(score, attrs) do
    score
    |> cast(attrs, [:player_name, :best_score, :total_score, :total_kills, :games_played, :last_played_at])
    |> validate_required([:player_name])
    |> validate_length(:player_name, min: 1, max: 32)
    |> unique_constraint(:player_name)
  end
end
