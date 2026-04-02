defmodule LurusWww.ReleasesClient do
  @moduledoc """
  Fetches release information from the releases API via Finch.
  """

  @doc "Fetch releases for a product. Returns {:ok, releases} or {:error, reason}"
  def fetch(product_id, opts \\ []) do
    api_url = Application.get_env(:lurus_www, :api_url, "https://api.lurus.cn")
    limit = Keyword.get(opts, :limit, 10)
    url = "#{api_url}/releases?product_id=#{product_id}&limit=#{limit}"

    case Finch.build(:get, url) |> Finch.request(LurusWww.Finch, receive_timeout: 10_000) do
      {:ok, %{status: 200, body: body}} ->
        {:ok, Jason.decode!(body)}

      {:ok, %{status: status}} ->
        {:error, {:http_error, status}}

      {:error, reason} ->
        {:error, reason}
    end
  end
end
