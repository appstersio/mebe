defmodule Mebe2.Web.Views.Tag do
  use Mebe2.Web.Views.BaseLayout,
    template: "tag.html.eex",
    arguments: [:tag, :posts, :total, :page]
end
