defmodule Mebe2.Engine.SlugUtils do
  @moduledoc """
  Utilities related to handling of slugs.
  """

  alias Mebe2.Engine.DB

  @doc """
  Get slug out of a given value.

  Nil is returned as is.
  """
  def slugify(nil), do: nil

  def slugify(value) do
    Slugger.slugify_downcase(value)
  end

  @doc """
  Get the author name related to this slug from the DB.
  """
  def unslugify_author(slug) do
    DB.get_author_name(slug)
  end
end
