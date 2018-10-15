defmodule Mebe2.Web.Views.SinglePost do
  use Mebe2.Web.Views.BaseLayout,
    template: "single_post.html.eex",
    arguments: [:post]
end
