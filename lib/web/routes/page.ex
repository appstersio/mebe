defmodule Mebe2.Web.Routes.Page do
  use Raxx.Server
  alias Mebe2.Engine.{DB, Models}

  @impl Raxx.Server
  def handle_request(%Raxx.Request{path: [slug]} = req, state) do
    with {:page, %Models.Page{} = page} <- {:page, DB.get_page(slug)} do
      response(200)
      |> Mebe2.Web.Views.Page.render(page)
    else
      _ -> Mebe2.Web.Routes.NotFound.handle_request(req, state)
    end
  end
end
