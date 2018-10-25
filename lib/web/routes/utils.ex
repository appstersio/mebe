defmodule Mebe2.Web.Routes.Utils do
  @moduledoc """
  Utility functions for routes-
  """

  alias Mebe2.Engine.Models.Post

  @doc """
  Parse page number in URL path.
  """
  @spec parse_page_number(String.t()) :: integer | :error
  def parse_page_number(maybe_number) do
    with {page, ""} <- Integer.parse(maybe_number),
         true <- page >= 0 do
      page
    else
      _ -> :error
    end
  end

  @doc """
  Get post range for the given page, i.e. the starting post and limit to display on that page.
  """
  @spec get_post_range(integer) :: {integer, integer}
  def get_post_range(page) when is_integer(page) do
    ppp = Mebe2.get_conf(:posts_per_page)
    {(page - 1) * ppp, ppp}
  end

  @doc """
  Render a set of posts on the given page. `page` is a string from the URL path, `post_getter` is
  a function that gets the range of posts to get and returns a list of posts, and `renderer` is a
  function that renders the given list of posts using the given response.
  """
  @spec render_posts(
          String.t(),
          (integer, integer -> [Post.t()]),
          (Raxx.Response.t(), [Post.t()] -> Raxx.Response.t())
        ) :: Raxx.Response.t()
  def render_posts(page \\ "1", post_getter, renderer) do
    case parse_page_number(page) do
      :error ->
        render_404()

      n ->
        {first, limit} = Mebe2.Web.Routes.Utils.get_post_range(n)
        posts = post_getter.(first, limit)
        Raxx.response(200) |> renderer.(posts)
    end
  end

  @doc """
  Render a 404 page.
  """
  @spec render_404() :: Raxx.Response.t()
  def render_404() do
    Raxx.response(404)
    |> Mebe2.Web.Views.NotFound.render()
  end
end
