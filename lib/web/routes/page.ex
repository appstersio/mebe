defmodule Mebe2.Web.Routes.Page do
  use Raxx.SimpleServer
  alias Mebe2.Engine.{DB, Models}
  alias Mebe2.Web.Routes.Utils

  @impl Raxx.SimpleServer
  def handle_request(%Raxx.Request{path: [slug]} = _req, _state) do
    with {:page, %Models.Page{} = page} <- {:page, DB.get_page(slug)} do
      Utils.html_response(200)
      |> Mebe2.Web.Views.Page.render(page)
    else
      _ -> Utils.render_404()
    end
  end
end
