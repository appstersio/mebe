defmodule Mebe2.Web.Routes.Month do
  use Raxx.SimpleServer
  alias Mebe2.Web.Routes.Utils

  @impl Raxx.SimpleServer
  def handle_request(
        %Raxx.Request{path: ["archive", year_str, month_str, "p", page]} = _req,
        _state
      ) do
    with {year, _} <- Integer.parse(year_str),
         {month, _} <- Integer.parse(month_str) do
      Utils.render_posts(
        page,
        &post_getter(year, month, &1, &2),
        &renderer(year, month, &1, &2, &3, &4)
      )
    else
      _ -> Utils.render_404()
    end
  end

  @impl Raxx.SimpleServer
  def handle_request(%Raxx.Request{path: ["archive", year_str, month_str, "feed"]} = _req, _state) do
    with {year, _} <- Integer.parse(year_str),
         {month, _} <- Integer.parse(month_str) do
      Utils.render_feed(&post_getter(year, month, &1, &2))
    else
      _ -> Utils.render_404()
    end
  end

  @impl Raxx.SimpleServer
  def handle_request(%Raxx.Request{path: ["archive", year_str, month_str]} = _req, _state) do
    with {year, _} <- Integer.parse(year_str),
         {month, _} <- Integer.parse(month_str) do
      Utils.render_posts(
        &post_getter(year, month, &1, &2),
        &renderer(year, month, &1, &2, &3, &4)
      )
    else
      _ -> Utils.render_404()
    end
  end

  defp post_getter(year, month, first, limit),
    do: {
      Mebe2.Engine.DB.get_month_posts(year, month, first, limit),
      Mebe2.Engine.DB.get_count(:month, {year, month})
    }

  defp renderer(year, month, response, posts, total, page),
    do: Utils.render_template(response, Mebe2.Web.Views.Month, [year, month, posts, total, page])
end
