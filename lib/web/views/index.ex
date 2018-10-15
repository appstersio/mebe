defmodule Mebe2.Web.Views.Index do
  use Mebe2.Web.Views.BaseLayout,
    template: "index.html.eex",
    arguments: [:posts]
end
