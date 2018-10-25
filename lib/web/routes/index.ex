defmodule Mebe2.Web.Routes.Index do
  use Raxx.Server
  alias Mebe2.Web.Views.Index

  @impl Raxx.Server
  def handle_request(%Raxx.Request{path: ["p", page]} = _req, _state) do
    Mebe2.Web.Routes.Utils.render_posts(page, &post_getter/2, &Index.render/2)
  end

  @impl Raxx.Server
  def handle_request(%Raxx.Request{} = _req, _state) do
    Mebe2.Web.Routes.Utils.render_posts(&post_getter/2, &Index.render/2)
  end

  defp post_getter(first, limit), do: Mebe2.Engine.DB.get_reg_posts(first, limit)
end
