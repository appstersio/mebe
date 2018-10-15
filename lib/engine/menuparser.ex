defmodule Mebe2.Engine.MenuParser do
  @moduledoc """
  This module handles the parsing of the menu file, which lists the links in the menu bar.
  """
  alias Mebe2.Engine.Models.MenuItem

  def parse(data_path) do
    (data_path <> "/menu")
    |> File.read!()
    |> split_lines
    |> parse_lines
    |> Enum.filter(fn item -> item != nil end)
  end

  defp split_lines(menudata) do
    String.split(menudata, ~R/\r?\n/)
  end

  defp parse_lines(menulines) do
    for line <- menulines do
      case String.split(line, " ") do
        [_] -> nil
        [link | rest] -> %MenuItem{slug: link, title: Enum.join(rest, " ")}
      end
    end
  end
end
