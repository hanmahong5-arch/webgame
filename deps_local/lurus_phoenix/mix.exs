defmodule LurusPhoenix.MixProject do
  use Mix.Project

  def project do
    [
      app: :lurus_phoenix,
      version: "0.1.0",
      elixir: "~> 1.17",
      elixirc_paths: elixirc_paths(Mix.env()),
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      description: "Shared Phoenix modules for Lurus web services (OIDC, ApiProxy, Auth, Health)"
    ]
  end

  def application do
    [
      extra_applications: [:logger, :crypto]
    ]
  end

  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]

  defp deps do
    [
      {:phoenix, "~> 1.7"},
      {:phoenix_html, "~> 4.1"},
      {:phoenix_live_view, "~> 1.0"},
      {:finch, "~> 0.18"},
      {:jason, "~> 1.4"},
      {:plug, "~> 1.16"},
      {:credo, "~> 1.7", only: [:dev, :test], runtime: false}
    ]
  end
end
