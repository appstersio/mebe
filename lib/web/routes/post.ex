defmodule Mebe2.Web.Routes.Post do
  use Raxx.SimpleServer
  alias Mebe2.Engine.{DB, Models}

  @impl Raxx.SimpleServer
  def handle_request(%Raxx.Request{path: [y_str, m_str, d_str, slug]} = _req, _state) do
    with {:year, {year, ""}} <- {:year, Integer.parse(y_str)},
         {:month, {month, ""}} <- {:month, Integer.parse(m_str)},
         {:day, {day, ""}} <- {:day, Integer.parse(d_str)},
         {:post, %Models.Post{} = post} <- {:post, DB.get_post(year, month, day, slug)} do
      response(200)
      |> Mebe2.Web.Views.SinglePost.render(post)
    else
      _ -> Mebe2.Web.Routes.Utils.render_404()
    end
  end
end
