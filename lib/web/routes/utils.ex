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
  You may optionally give the posts per page limit to use when constructing the range.
  """
  @spec get_post_range(integer, integer | nil) :: {integer, integer}
  def get_post_range(page, posts_per_page \\ nil) when is_integer(page) do
    ppp = if is_nil(posts_per_page), do: Mebe2.get_conf(:posts_per_page), else: posts_per_page
    {(page - 1) * ppp, ppp}
  end

  @doc """
  Render a set of posts on the given page.

  - `page` is a string from the URL path.
  - `post_getter` is a function that gets the range of posts to load and returns a tuple where the
    first element is the list of found posts, and the second element is the amount of all posts
    that are in the DB with these conditions.
  - `renderer` is a function that renders the content. Its arguments are the response to use,
    the list of posts to render, the total amount of posts for pagination, and the current page
    number.
  """
  @spec render_posts(
          String.t(),
          (integer, integer -> {[Post.t()], integer}),
          (Raxx.Response.t(), [Post.t()], integer, integer -> Raxx.Response.t())
        ) :: Raxx.Response.t()
  def render_posts(page \\ "1", post_getter, renderer) do
    with n when is_integer(n) <- parse_page_number(page),
         {first, limit} = get_post_range(n),
         {[_ | _] = posts, total} <- post_getter.(first, limit) do
      html_response(200) |> renderer.(posts, total, n)
    else
      _ -> render_404()
    end
  end

  @doc """
  Render RSS feed for the given posts.

  `post_getter` is a function that gets the range of posts to load and returns a tuple where the
  first element is the list of found posts and the second element can be anything (the structure)
  is the same as in `render_posts` so that the post getters can be reused.
  """
  @spec render_feed((integer, integer -> {[Post.t()], any})) :: Raxx.Response.t()
  def render_feed(post_getter) do
    with true <- Mebe2.get_conf(:enable_feeds) do
      {first, limit} = get_post_range(1, Mebe2.get_conf(:posts_in_feed))
      {posts, _} = post_getter.(first, limit)

      rss_response(200)
      |> render_template(Mebe2.Web.Views.Feeds.PostList, [posts])
    else
      _ -> render_404()
    end
  end

  @doc """
  Render a 404 page.
  """
  @spec render_404() :: Raxx.Response.t()
  def render_404() do
    html_response(404)
    |> render_template(Mebe2.Web.Views.NotFound)
  end

  @doc """
  Get an HTML response with the proper content type.
  """
  @spec html_response(integer) :: Raxx.Response.t()
  def html_response(code) when is_integer(code) do
    Raxx.response(code)
    |> Raxx.set_header("content-type", "text/html; charset=utf-8")
  end

  @doc """
  Get an RSS response with the proper content type.
  """
  @spec rss_response(integer) :: Raxx.Response.t()
  def rss_response(code) when is_integer(code) do
    Raxx.response(code)
    |> Raxx.set_header("content-type", "application/xml+rss; charset=utf-8")
  end

  @doc """
  Render a template with the given args into the response.
  """
  @spec render_template(Raxx.Response.t(), module, [any]) :: Raxx.Response.t()
  def render_template(response, template, args \\ []) do
    Raxx.set_body(response, apply(template, :html, args).data)
  end
end
