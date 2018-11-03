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

  @doc """
  Format the given year and month into a human readable nice string.

  ## Examples

      iex> Mebe2.Web.Views.Utils.format_month(2014, 12)
      "December 2014"

      iex> Mebe2.Web.Views.Utils.format_month(2015, 4)
      "April 2015"
  """
  @spec format_month(integer, integer) :: String.t()
  def format_month(year, month) do
    Date.from_erl!({year, month, 1})
    |> Calendar.Strftime.strftime!("%B %Y")
  end

  @doc """
  Pad the month for path generation.
  """
  @spec pad_month(integer) :: String.t()
  def pad_month(month), do: Integer.to_string(month) |> String.pad_leading(2, "0")

  @doc """
  Get path generator for the given year.
  """
  @spec year_path_generator(integer) :: (integer -> String.t())
  def year_path_generator(year), do: &"/archive/#{year}/p/#{&1}"

  @doc """
  Get path generator for the given year and month combo.
  """
  @spec month_path_generator(integer, integer) :: (integer -> String.t())
  def month_path_generator(year, month), do: &"/archive/#{year}/#{pad_month(month)}/p/#{&1}"
end
