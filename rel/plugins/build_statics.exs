defmodule Mebe2.ReleasePlugins.BuildStatics do
  use Mix.Releases.Plugin

  @moduledoc """
  Distillery plugin for generating static files (i.e. the frontend) before building the release.
  """

  def before_assembly(release, _opts) do
    info("Building static assets for release")

    # Minify assets if generating prod release
    if Mix.env() == :prod do
      System.put_env("NODE_ENV", "production")
    end

    Mix.Task.run("mebe.build.frontend")
    release
  end

  def after_assembly(release, _opts), do: release
  def before_package(release, _opts), do: release
  def after_package(release, _opts), do: release
end
