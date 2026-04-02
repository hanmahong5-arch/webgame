defmodule LurusWww.Chat.RateLimiter do
  @moduledoc """
  ETS-based rate limiter for chat sessions.
  Limits requests per session to prevent abuse.
  """

  @table :chat_rate_limiter
  @max_requests 20
  @window_ms 60_000

  def init do
    :ets.new(@table, [:set, :public, :named_table])
  rescue
    ArgumentError -> :ok
  end

  @doc "Check if a session key is within rate limits. Returns :ok or {:error, :rate_limited}"
  def check(session_key) do
    now = System.monotonic_time(:millisecond)
    window_start = now - @window_ms

    case :ets.lookup(@table, session_key) do
      [{^session_key, timestamps}] ->
        recent = Enum.filter(timestamps, &(&1 > window_start))

        if length(recent) < @max_requests do
          :ets.insert(@table, {session_key, [now | recent]})
          :ok
        else
          {:error, :rate_limited}
        end

      [] ->
        :ets.insert(@table, {session_key, [now]})
        :ok
    end
  end

  @doc "Clean up expired entries"
  def cleanup do
    now = System.monotonic_time(:millisecond)
    window_start = now - @window_ms

    :ets.foldl(
      fn {key, timestamps}, acc ->
        recent = Enum.filter(timestamps, &(&1 > window_start))
        if recent == [], do: :ets.delete(@table, key), else: :ets.insert(@table, {key, recent})
        acc
      end,
      :ok,
      @table
    )
  end
end
