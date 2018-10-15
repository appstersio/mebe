defmodule Mebe2.Web.Routes.NotFound do
  use Raxx.Server

  @impl Raxx.Server
  def handle_request(_req, _state) do
    response(404)
    |> Mebe2.Web.Views.NotFound.render()
  end
end
