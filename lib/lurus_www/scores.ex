defmodule LurusWww.Scores do
  @moduledoc "Persistent leaderboard and player score tracking."

  import Ecto.Query
  alias LurusWww.Repo
  alias LurusWww.Scores.PlayerScore

  @doc "Record a game session result. Upserts by player_name."
  def record_score(player_name, score, kills) do
    now = DateTime.utc_now() |> DateTime.truncate(:second)

    %PlayerScore{}
    |> PlayerScore.changeset(%{
      player_name: player_name,
      best_score: score,
      total_score: score,
      total_kills: kills,
      games_played: 1,
      last_played_at: now
    })
    |> Repo.insert(
      on_conflict: [
        inc: [total_score: score, total_kills: kills, games_played: 1],
        set: [
          best_score: fragment("GREATEST(?, ?)", ^score, fragment("EXCLUDED.best_score")),
          last_played_at: now
        ]
      ],
      conflict_target: :player_name
    )
  end

  @doc "Get all-time top players."
  def top_players(limit \\ 20) do
    PlayerScore
    |> order_by(desc: :total_score)
    |> limit(^limit)
    |> Repo.all()
  end

  @doc "Get today's top players."
  def today_top(limit \\ 10) do
    today = Date.utc_today()

    PlayerScore
    |> where([p], fragment("?::date", p.last_played_at) == ^today)
    |> order_by(desc: :total_score)
    |> limit(^limit)
    |> Repo.all()
  end
end
