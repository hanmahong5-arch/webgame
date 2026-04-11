defmodule LurusWww.Games.AutoRoom do
  @moduledoc "Automatic room management. Always has a room available."

  alias LurusWww.Games.{GameServer, GameSupervisor}

  @max_per_room 20

  @doc "Find an available room or create one. Returns room_id."
  def find_or_create do
    rooms = GameServer.list_rooms()

    # Find a room with space
    available = Enum.find(rooms, fn r -> r.player_count < @max_per_room end)

    case available do
      %{room_id: id} -> id
      nil -> create_new_room()
    end
  end

  defp create_new_room do
    room_id = GameSupervisor.generate_room_id()
    case GameSupervisor.create_room(room_id) do
      {:ok, _} -> room_id
      _ -> create_new_room()
    end
  end
end
