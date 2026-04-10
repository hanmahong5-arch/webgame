defmodule LurusWww.Scores do
  @moduledoc "Persistent leaderboard and player score tracking."

  import Ecto.Query
  alias LurusWww.Repo
  alias LurusWww.Scores.PlayerScore

  @doc "Record a game session. Creates or updates player record."
  def record_score(player_name, score, kills) when is_binary(player_name) and score > 0 do
    now = DateTime.utc_now() |> DateTime.truncate(:second)

    case Repo.get_by(PlayerScore, player_name: player_name) do
      nil ->
        %PlayerScore{}
        |> PlayerScore.changeset(%{
          player_name: player_name,
          best_score: score,
          total_score: score,
          total_kills: kills,
          games_played: 1,
          last_played_at: now
        })
        |> Repo.insert()

      existing ->
        existing
        |> PlayerScore.changeset(%{
          best_score: max(existing.best_score, score),
          total_score: existing.total_score + score,
          total_kills: existing.total_kills + kills,
          games_played: existing.games_played + 1,
          last_played_at: now
        })
        |> Repo.update()
    end
  rescue
    _ -> :error
  end

  def record_score(_, _, _), do: :ok

  @doc "All-time top players."
  def top_players(limit \\ 20) do
    PlayerScore
    |> order_by(desc: :total_score)
    |> limit(^limit)
    |> Repo.all()
  rescue
    _ -> []
  end
end
