defmodule Mebe2.Web.Views.Year do
  use Mebe2.Web.Views.BaseLayout,
    template: "year.html.eex",
    arguments: [:year, :posts, :total, :page]
end
