defmodule Mebe2.Web.Views.Month do
  use Mebe2.Web.Views.BaseLayout,
    template: "month.html.eex",
    arguments: [:year, :month, :posts, :total, :page]

  def title(vars) do
    year = Keyword.get(vars, :year)
    month = Keyword.get(vars, :month)

    "Archives: #{Mebe2.Web.Views.Utils.format_month(year, month)}"
  end
end
