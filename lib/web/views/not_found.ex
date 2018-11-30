defmodule Mebe2.Web.Views.NotFound do
  use Mebe2.Web.Views.BaseLayout,
    template: "not_found.html.eex",
    arguments: []

  def title(_) do
    "404 Not Found"
  end
end
