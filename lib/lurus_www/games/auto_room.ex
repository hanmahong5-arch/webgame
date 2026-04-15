defmodule LurusWww.Games.AutoRoom do
  @moduledoc """
  Automatic room management.
  - MAIN room is always available (never idle-destroyed)
  - Overflow rooms created when MAIN full, auto-destroyed when empty
  """

  alias LurusWww.Games.{GameServer, GameSupervisor}

  @max_per_room 20
  @main_room "MAIN"

  @doc "Find available room, prefer MAIN. Ensure MAIN exists."
  def find_or_create do
    # Ensure MAIN always exists
    unless GameServer.room_exists?(@main_room) do
      GameSupervisor.create_room(@main_room)
    end

    # Prefer MAIN if it has space
    case GameServer.get_summary(@main_room) do
      {:ok, %{player_count: c}} when c < @max_per_room -> @main_room
      _ -> find_overflow_or_new()
    end
  end

  defp find_overflow_or_new do
    available =
      GameServer.list_rooms()
      |> Enum.reject(&(&1.room_id == @main_room))
      |> Enum.find(fn r -> r.player_count < @max_per_room end)

    case available do
      %{room_id: id} -> id
      nil -> create_new_overflow()
    end
  end

  defp create_new_overflow do
    id = GameSupervisor.generate_room_id()
    case GameSupervisor.create_room(id) do
      {:ok, _} -> id
      _ -> create_new_overflow()
    end
  end
end
