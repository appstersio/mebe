defmodule Mebe2.MixProject do
  use Mix.Project

  def project do
    [
      app: :mebe_2,
      version: "0.1.0",
      elixir: "~> 1.7",
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
      {:earmark, "~> 1.2.5"},
      {:raxx, "~> 0.16.1"},
      {:ace, "~> 0.17.1"},
      {:calendar, "~> 0.17.4"},
      {:slugger, "~> 0.3.0"},
      {:mbu, "~> 3.0.0", runtime: false},
      {:exsync, "~> 0.2.3", only: :dev}
    ]
  end
end
