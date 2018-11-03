defmodule Mebe2.Web.Routes.Tag do
  use Raxx.Server
  alias Mebe2.Web.Routes.Utils

  @impl Raxx.Server
  def handle_request(%Raxx.Request{path: ["tag", tag, "p", page]} = _req, _state) do
    Utils.render_posts(
      page,
      &post_getter(tag, &1, &2),
      &renderer(tag, &1, &2, &3, &4)
    )
  end

  @impl Raxx.Server
  def handle_request(%Raxx.Request{path: ["tag", tag, "feed"]} = _req, _state) do
    Utils.render_feed(&post_getter(tag, &1, &2))
  end

  @impl Raxx.Server
  def handle_request(%Raxx.Request{path: ["tag", tag]} = _req, _state) do
    Utils.render_posts(&post_getter(tag, &1, &2), &renderer(tag, &1, &2, &3, &4))
  end

  defp post_getter(tag, first, limit),
    do: {
      Mebe2.Engine.DB.get_tag_posts(tag, first, limit),
      Mebe2.Engine.DB.get_count(:tag, tag)
    }

  defp renderer(tag, response, posts, total, page),
    do: Mebe2.Web.Views.Tag.render(response, tag, posts, total, page)
end
