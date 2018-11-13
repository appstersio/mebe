defmodule Mebe2.Web.Routes.NotFound do
  use Raxx.SimpleServer

  @impl Raxx.SimpleServer
  def handle_request(_req, _state) do
    Mebe2.Web.Routes.Utils.render_404()
  end
end
