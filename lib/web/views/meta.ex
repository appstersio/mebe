defmodule Mebe2.Web.Views.Meta do
  import Mebe2.Web.Views.BaseLayout, only: [render_title: 2]

  use Raxx.View,
    template: "meta.html.eex",
    arguments: [:module, :vars]

  alias Mebe2.Web.Views.SinglePost, as: PostView
  alias Mebe2.Web.Views.Page, as: PageView
  alias Mebe2.Engine.Models.Post, as: PostModel

  @doc """
  Get the description of this page for search engines. Posts use the "description" header, if
  available. Fallback is to `:blog_description.`
  """
  @spec description(module, keyword) :: String.t()
  def description(module, vars)

  def description(PostView, vars) do
    %PostModel{} = post = Keyword.get(vars, :post)
    Map.get(post.extra_headers, "description", Mebe2.get_conf(:blog_description))
  end

  def description(_module, _vars), do: Mebe2.get_conf(:blog_description)

  @doc """
  Get the author for Twitter, or empty string if not set.
  """
  @spec twitter_author() :: String.t()
  def twitter_author() do
    case Mebe2.get_conf(:blog_author_twitter) do
      nil -> ""
      author -> "@#{author}"
    end
  end

  @doc """
  Get the OpenGraph type for this page. Pages and posts are type "article", others are type
  "website".
  """
  @spec og_type(module, keyword) :: String.t()
  def og_type(module, vars)

  def og_type(m, _vars) when m in [PostView, PageView], do: "article"
  def og_type(_module, _vars), do: "website"

  @doc """
  Get the canonical URL for this page. Only pages and posts have this, it's not that useful for
  other views so it's not defined for them.
  """
  @spec url(PostView | PageView, keyword) :: String.t()
  def url(module, vars)

  def url(PostView, vars) do
    %PostModel{} = post = Keyword.get(vars, :post)
    Mebe2.get_conf(:absolute_url) <> Mebe2.Web.Views.Utils.get_post_path(post)
  end

  def url(PageView, vars) do
    %Mebe2.Engine.Models.Page{} = page = Keyword.get(vars, :page)
    Mebe2.get_conf(:absolute_url) <> Mebe2.Web.Views.Utils.get_page_path(page)
  end

  @doc """
  Get the ISO 8601 timestamp for this post.
  """
  @spec timestamp(PostView, keyword) :: String.t()
  def timestamp(PostView, vars) do
    %PostModel{} = post = Keyword.get(vars, :post)
    DateTime.to_iso8601(post.datetime)
  end

  @doc """
  Get the image, if any, for this post. Uses the "image" header.
  """
  @spec image(PostView, keyword) :: String.t()
  def image(PostView, vars) do
    %PostModel{} = post = Keyword.get(vars, :post)
    Map.get(post.extra_headers, "image", "")
  end
end
