defmodule Mebe2.Web.Routes.Year do
  use Raxx.SimpleServer
  alias Mebe2.Web.Routes.Utils

  @impl Raxx.SimpleServer
  def handle_request(%Raxx.Request{path: ["archive", year_str, "p", page]} = _req, _state) do
    with {year, _} <- Integer.parse(year_str) do
      Utils.render_posts(
        page,
        &post_getter(year, &1, &2),
        &renderer(year, &1, &2, &3, &4)
      )
    else
      _ -> Utils.render_404()
    end
  end

  @impl Raxx.SimpleServer
  def handle_request(%Raxx.Request{path: ["archive", year_str, "feed"]} = _req, _state) do
    with {year, _} <- Integer.parse(year_str) do
      Utils.render_feed(&post_getter(year, &1, &2))
    else
      _ -> Utils.render_404()
    end
  end

  @impl Raxx.SimpleServer
  def handle_request(%Raxx.Request{path: ["archive", year_str]} = _req, _state) do
    with {year, _} <- Integer.parse(year_str) do
      Utils.render_posts(
        &post_getter(year, &1, &2),
        &renderer(year, &1, &2, &3, &4)
      )
    else
      _ -> Utils.render_404()
    end
  end

  defp post_getter(year, first, limit),
    do: {
      Mebe2.Engine.DB.get_year_posts(year, first, limit),
      Mebe2.Engine.DB.get_count(:year, year)
    }

  defp renderer(year, response, posts, total, page),
    do: Utils.render_template(response, Mebe2.Web.Views.Year, [year, posts, total, page])
end
