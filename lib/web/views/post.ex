defmodule Mebe2.Web.Views.Post do
  use Raxx.View,
    template: "post.html.eex",
    arguments: [:post, :multi]

  @doc """
  Format a datetime for display in the blog.
  """
  @spec format_datetime(DateTime.t()) :: String.t()
  def format_datetime(%DateTime{} = dt) do
    Calendar.Strftime.strftime!(dt, "%e %b %Y, %R %Z")
  end

  @doc """
  Format a date for display in the blog.
  """
  @spec format_date(DateTime.t()) :: String.t()
  def format_date(%DateTime{} = dt) do
    Calendar.Strftime.strftime!(dt, "%e %b %Y")
  end
end
