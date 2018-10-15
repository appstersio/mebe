defmodule Mebe2.Web.Views.Utils do
  @moduledoc """
  Utility functions to use in views.
  """

  @doc """
  Get the relative path to a given post.

  ## Examples

      iex> Mebe2.Web.Views.Utils.get_post_path(
      ...>   %Mebe2.Engine.Models.Post{datetime: ~N[2010-08-09T10:00:00], slug: "foo-bar"}
      ...> )
      "/2010/08/09/foo-bar"
  """
  def get_post_path(%Mebe2.Engine.Models.Post{} = post) do
    dstr = Calendar.Strftime.strftime!(post.datetime, "%Y/%m/%d")
    "/#{dstr}/#{post.slug}"
  end
end
