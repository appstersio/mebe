defmodule Mebe2.Web.Views.Month do
  use Mebe2.Web.Views.BaseLayout,
    template: "month.html.eex",
    arguments: [:year, :month, :posts, :total, :page]
end
