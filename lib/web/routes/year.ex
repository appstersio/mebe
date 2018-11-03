defmodule Mebe2.Web.Routes.Year do
  use Raxx.Server

  @impl Raxx.Server
  def handle_request(%Raxx.Request{path: ["archive", year_str, "p", page]} = _req, _state) do
    with {year, _} <- Integer.parse(year_str) do
      Mebe2.Web.Routes.Utils.render_posts(
        page,
        &post_getter(year, &1, &2),
        &renderer(year, &1, &2, &3, &4)
      )
    else
      _ -> Mebe2.Web.Routes.Utils.render_404()
    end
  end

  @impl Raxx.Server
  def handle_request(%Raxx.Request{path: ["archive", year_str]} = _req, _state) do
    with {year, _} <- Integer.parse(year_str) do
      Mebe2.Web.Routes.Utils.render_posts(
        &post_getter(year, &1, &2),
        &renderer(year, &1, &2, &3, &4)
      )
    else
      _ -> Mebe2.Web.Routes.Utils.render_404()
    end
  end

  defp post_getter(year, first, limit),
    do: {
      Mebe2.Engine.DB.get_year_posts(year, first, limit),
      Mebe2.Engine.DB.get_count(:year, year)
    }

  defp renderer(year, response, posts, total, page),
    do: Mebe2.Web.Views.Year.render(response, year, posts, total, page)
end
