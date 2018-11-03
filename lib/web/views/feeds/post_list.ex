defmodule Mebe2.Web.Views.Feeds.PostList do
  use Mebe2.Web.Views.Feeds.BaseLayout,
    template: "post_list.xml.eex",
    arguments: [:posts]

  @doc """
  Format datetime for RSS usage.
  """
  @spec format_time(DateTime.t()) :: String.t()
  def format_time(datetime) do
    Calendar.Strftime.strftime!(datetime, "%a, %d %b %Y %T %z")
  end
end
