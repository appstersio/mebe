defmodule Mebe2.Web.Views.SinglePost do
  use Mebe2.Web.Views.BaseLayout,
    template: "single_post.html.eex",
    arguments: [:post]

  def title(vars) do
    Keyword.get(vars, :post).title
  end
end
