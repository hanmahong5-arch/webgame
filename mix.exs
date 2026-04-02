defmodule LurusWww.MixProject do
  use Mix.Project

  def project do
    [
      app: :lurus_www,
      version: "0.1.0",
      elixir: "~> 1.17",
      elixirc_paths: elixirc_paths(Mix.env()),
      start_permanent: Mix.env() == :prod,
      compilers: [:phoenix_live_view] ++ Mix.compilers(),
      listeners: [Phoenix.CodeReloader],
      aliases: aliases(),
      deps: deps()
    ]
  end

  def application do
    [
      mod: {LurusWww.Application, []},
      extra_applications: [:logger, :runtime_tools]
    ]
  end

  def cli do
    [preferred_envs: [precommit: :test]]
  end

  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]

  defp deps do
    [
      {:lurus_phoenix, path: "../shared/lurus_phoenix"},
      {:phoenix, "~> 1.7"},
      {:phoenix_html, "~> 4.1"},
      {:phoenix_live_view, "~> 1.0"},
      {:phoenix_live_reload, "~> 1.5", only: :dev},
      {:phoenix_live_dashboard, "~> 0.8"},
      {:bandit, "~> 1.5"},
      {:finch, "~> 0.18"},
      {:tailwind, "~> 0.2", runtime: Mix.env() == :dev},
      {:esbuild, "~> 0.8", runtime: Mix.env() == :dev},
      {:earmark, "~> 1.4"},
      {:html_sanitize_ex, "~> 1.4"},
      {:telemetry_metrics, "~> 1.0"},
      {:telemetry_poller, "~> 1.0"},
      {:jason, "~> 1.4"},
      {:gettext, "~> 0.26"},
      {:dns_cluster, "~> 0.1"},
      {:credo, "~> 1.7", only: [:dev, :test], runtime: false},
      {:floki, "~> 0.37", only: :test}
    ]
  end

  defp aliases do
    [
      setup: ["deps.get", "assets.setup", "assets.build"],
      "assets.setup": ["tailwind.install --if-missing", "esbuild.install --if-missing"],
      "assets.build": ["compile", "tailwind lurus_www", "esbuild lurus_www"],
      "assets.deploy": [
        "tailwind lurus_www --minify",
        "esbuild lurus_www --minify",
        "phx.digest"
      ],
      precommit: ["compile --warnings-as-errors", "deps.unlock --unused", "format", "test"]
    ]
  end
end
