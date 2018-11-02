defmodule Mebe2.Web.Views.Pagination do
  use Raxx.View,
    template: "pagination.html.eex",
    arguments: [:total, :page, :path_generator]

  @doc """
  Get amount of posts per page.
  """
  @spec ppp() :: integer
  def ppp(), do: Mebe2.get_conf(:posts_per_page)

  @doc """
  Get total amount of pages based on the amount of posts.
  """
  @spec total_pages(integer) :: integer
  def total_pages(total_posts), do: (total_posts / ppp()) |> Float.ceil() |> trunc()

  @doc """
  Get path to given page formed with path generator.
  """
  @spec path((integer -> String.t()), integer) :: String.t()
  def path(path_gen, page), do: "#{Mebe2.get_conf(:absolute_url)}#{path_gen.(page)}"

  @doc """
  Get pagination link with path generator for the path, current page, and should the link be
  disabled.
  """
  @spec link((integer -> String.t()), integer, boolean(), String.t() | nil) :: EExHTML.Safe.t()
  def link(path_gen, page, is_disabled, page_str \\ nil) do
    page_str =
      case page_str do
        nil -> Integer.to_string(page)
        str -> str
      end

    ~E"""
      <div
        class="pagination-link <%= if is_disabled, do: ~s(pagination-disabled) %>"
      >
        <%= raw(if not is_disabled do %>
          <a
            href="<%= path(path_gen, page) %>"
          >
            <%= page_str %>
          </a>
        <% else %>
          <%= page_str %>
        <% end) %>
      </div>
    """
  end
end
