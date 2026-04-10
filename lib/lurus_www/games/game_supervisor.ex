defmodule LurusWww.Games.GameSupervisor do
  @moduledoc "DynamicSupervisor for game room processes."

  use DynamicSupervisor

  def start_link(init_arg) do
    DynamicSupervisor.start_link(__MODULE__, init_arg, name: __MODULE__)
  end

  @impl true
  def init(_init_arg) do
    DynamicSupervisor.init(strategy: :one_for_one)
  end

  def create_room(room_id) do
    spec = {LurusWww.Games.GameServer, room_id: room_id}
    DynamicSupervisor.start_child(__MODULE__, spec)
  end

  def generate_room_id do
    id = for _ <- 1..4, into: "", do: <<Enum.random(?A..?Z)>>

    if LurusWww.Games.GameServer.room_exists?(id) do
      generate_room_id()
    else
      id
    end
  end
end
