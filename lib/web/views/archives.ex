defmodule Mebe2.Web.Views.Archives do
  use Raxx.View,
    template: "archives.html.eex",
    arguments: []

  @doc """
  Get list of tuples {year, month} that have at least one post.
  """
  @spec get_archives() :: [{integer, [{integer, integer}]}]
  def get_archives() do
    Mebe2.Web.Middleware.Archives.get_archives()
    |> Enum.chunk_by(fn {year, _} -> year end)
    |> Enum.map(fn [{year, _} | _] = list ->
      {year, Enum.map(list, fn {_, month} -> month end)}
    end)
  end
end
