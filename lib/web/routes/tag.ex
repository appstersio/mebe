defmodule Mebe2.Web.Routes.Tag do
  use Raxx.Server

  @impl Raxx.Server
  def handle_request(%Raxx.Request{path: ["tag", tag, "p", page]} = _req, _state) do
    Mebe2.Web.Routes.Utils.render_posts(page, &post_getter(tag, &1, &2), &renderer(tag, &1, &2))
  end

  @impl Raxx.Server
  def handle_request(%Raxx.Request{path: ["tag", tag]} = _req, _state) do
    Mebe2.Web.Routes.Utils.render_posts(&post_getter(tag, &1, &2), &renderer(tag, &1, &2))
  end

  defp post_getter(tag, first, limit), do: Mebe2.Engine.DB.get_tag_posts(tag, first, limit)

  defp renderer(tag, response, posts), do: Mebe2.Web.Views.Tag.render(response, tag, posts)
end
