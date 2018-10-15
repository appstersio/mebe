defmodule Mebe2.Engine.Utils do
  @moduledoc """
  This module contains functions and other stuff that just don't fit anywhere else properly.
  """

  alias Mebe2.Engine.Models

  @doc """
  Get the author of a post.

  Returns a value according to the following pseudocode

  if multi author mode is on then
    if post has author then
      return post's author
    else if use default author is on then
      return blog author
    else return nil
  else if use default author is on then
    return blog author
  else return nil
  """
  @spec get_author(Models.Post.t()) :: String.t() | nil
  def get_author(%Models.Post{extra_headers: extra_headers}) do
    multi_author_mode = Mebe2.get_conf(:multi_author_mode)
    use_default_author = Mebe2.get_conf(:use_default_author)
    blog_author = Mebe2.get_conf(:blog_author)

    if multi_author_mode do
      cond do
        Map.has_key?(extra_headers, "author") ->
          Map.get(extra_headers, "author")

        use_default_author ->
          blog_author

        true ->
          nil
      end
    else
      if use_default_author, do: blog_author, else: nil
    end
  end
end
