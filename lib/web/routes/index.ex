defmodule Mebe2.Web.Routes.Index do
  use Raxx.SimpleServer
  alias Mebe2.Web.Views.Index
  alias Mebe2.Web.Routes.Utils

  @impl Raxx.SimpleServer
  def handle_request(%Raxx.Request{path: ["p", page]} = _req, _state) do
    Utils.render_posts(page, &post_getter/2, &renderer/4)
  end

  @impl Raxx.SimpleServer
  def handle_request(%Raxx.Request{path: ["feed"]} = _req, _state) do
    Utils.render_feed(&post_getter/2)
  end

  @impl Raxx.SimpleServer
  def handle_request(%Raxx.Request{} = _req, _state) do
    Utils.render_posts(&post_getter/2, &renderer/4)
  end

  defp renderer(response, posts, total, page) do
    Utils.render_template(response, Index, [posts, total, page])
  end

  defp post_getter(first, limit),
    do: {
      Mebe2.Engine.DB.get_reg_posts(first, limit),
      Mebe2.Engine.DB.get_count(:all)
    }
end
