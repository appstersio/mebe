defmodule Mebe2.Web.Routes.Index do
  use Raxx.Server
  alias Mebe2.Engine.DB

  @impl Raxx.Server
  def handle_request(%Raxx.Request{} = _req, _state) do
    posts = DB.get_reg_posts(0, Mebe2.get_conf(:posts_per_page))

    response(200)
    |> Mebe2.Web.Views.Index.render(posts)
  end
end
