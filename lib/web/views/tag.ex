defmodule Mebe2.Web.Views.Tag do
  use Mebe2.Web.Views.BaseLayout,
    template: "tag.html.eex",
    arguments: [:tag, :posts, :total, :page]

  def title(vars) do
    tag = Keyword.get(vars, :tag)

    "Archives: tag #{tag}"
  end
end
