defmodule Mebe2.Web.Views.Archives do
  use Raxx.View,
    template: "archives.html.eex",
    arguments: []

  @doc """
  Get list of tuples {year, month} that have at least one post.
  """
  @spec get_month_archives() :: [{integer, [{integer, integer}]}]
  def get_month_archives() do
    Mebe2.Web.Middleware.Archives.get_month_archives()
    |> Enum.chunk_by(fn {year, _} -> year end)
    |> Enum.map(fn [{year, _} | _] = list ->
      {year, Enum.map(list, fn {_, month} -> month end)}
    end)
  end

  @doc """
  Get tuple with first element being a keyword list of {tag, post_amount}, and the second element
  being the amount of posts for the most used tag.
  """
  @spec get_tags() :: {integer, [{String.t(), integer}]}
  def get_tags() do
    tags =
      Mebe2.Web.Middleware.Archives.get_tag_archives()
      |> Map.to_list()
      |> Enum.sort_by(fn {tag, _} -> tag end)

    {_, max} = Enum.max_by(tags, fn {_, count} -> count end)
    {max, tags}
  end
end
