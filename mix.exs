defmodule Mebe2.MixProject do
  use Mix.Project

  def project do
    [
      app: :mebe_2,
      version: "0.3.0",
      elixir: "~> 1.10",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger],
      mod: {Mebe2.Application, []}
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:earmark, "~> 1.4"},
      {:raxx, "~> 1.1"},
      {:raxx_static, "~> 0.8.3"},
      {:raxx_view, "~> 0.1.7"},
      {:raxx_logger, "~> 0.2.2"},
      {:eex_html, "~> 1.0"},
      {:ace, "~> 0.18.10"},
      {:calendar, "~> 1.0"},
      {:ex2ms, "~> 1.6"},
      {:mbu, "~> 3.0", runtime: false},
      {:exsync, "~> 0.2.4", only: :dev}
    ]
  end
end
