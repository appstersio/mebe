defmodule Mebe2.Web.Views.BaseLayout do
  use Raxx.Layout,
    layout: "base_layout.html.eex"

  alias Mebe2.Web.Views.SinglePost

  @doc """
  Render title for this page, based on the given module. If the module has a title/1 function, it
  will be used to get the title to use, but a postfix with the blog name will be added. The title
  function will be given the vars added to this function.
  """
  @spec render_title(module, keyword()) :: String.t()
  def render_title(module, vars) do
    if function_exported?(module, :title, 1) do
      "#{apply(module, :title, [vars])} – #{Mebe2.get_conf(:blog_name)}"
    else
      Mebe2.get_conf(:blog_name)
    end
  end

  @doc """
  Get Schema.org type for this page, either Blog or BlogPosting.
  """
  @spec schema_type(module, keyword) :: String.t()
  def schema_type(module, vars)

  def schema_type(SinglePost, _vars), do: "BlogPosting"
  def schema_type(_module, _vars), do: "Blog"
end
