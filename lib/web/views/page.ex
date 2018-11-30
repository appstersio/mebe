defmodule Mebe2.Web.Views.Page do
  use Mebe2.Web.Views.BaseLayout,
    template: "page.html.eex",
    arguments: [:page]

  def title(vars) do
    Keyword.get(vars, :page).title
  end
end
