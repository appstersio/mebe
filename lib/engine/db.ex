defmodule Mebe2.Engine.DB do
  require Logger
  import Ex2ms
  alias Mebe2.Engine.Models

  alias Calendar.DateTime

  @moduledoc """
  Stuff related to storing the blog data to memory (ETS).
  """

  # Table for meta information, like the counts of posts and names
  # of authors
  @meta_table :mebe2_meta

  # Table for storing pages by slug
  @page_table :mebe2_pages

  # Table for sequential retrieval of posts (for list pages)
  @post_table :mebe2_posts

  # Table for quick retrieval of single post (with key)
  @single_post_table :mebe2_single_posts

  # Table for storing posts with tag as first element of key
  @tag_table :mebe2_tags

  # Table for storing menu data
  @menu_table :mebe2_menu

  @spec init() :: :ok
  def init() do
    # Only create tables if they don't exist already
    if :ets.info(@meta_table) == :undefined do
      :ets.new(@meta_table, [:named_table, :set, :protected, read_concurrency: true])
      :ets.new(@page_table, [:named_table, :set, :protected, read_concurrency: true])
      :ets.new(@post_table, [:named_table, :ordered_set, :protected, read_concurrency: true])
      :ets.new(@single_post_table, [:named_table, :set, :protected, read_concurrency: true])
      :ets.new(@tag_table, [:named_table, :ordered_set, :protected, read_concurrency: true])
      :ets.new(@menu_table, [:named_table, :ordered_set, :protected, read_concurrency: true])
    end

    :ok
  end

  @spec destroy() :: :ok
  def destroy() do
    :ets.delete_all_objects(@meta_table)
    :ets.delete_all_objects(@page_table)
    :ets.delete_all_objects(@post_table)
    :ets.delete_all_objects(@single_post_table)
    :ets.delete_all_objects(@tag_table)
    :ok
  end

  @spec insert_count(:all, integer) :: true
  def insert_count(:all, count) do
    insert_meta(:all, :all, count)
  end

  @spec insert_count(atom, String.t() | integer, integer) :: true
  def insert_count(type, key, count) do
    insert_meta(type, key, count)
  end

  @spec insert_menu([{String.t(), String.t()}]) :: true
  def insert_menu(menu) do
    # Format for ETS because it needs a tuple
    menu = Enum.map(menu, fn menuitem -> {menuitem.slug, menuitem} end)
    :ets.insert(@menu_table, menu)
  end

  @spec insert_posts([Models.Post.t()]) :: :ok
  def insert_posts(posts) do
    ordered_posts =
      Enum.map(posts, fn post ->
        {{year, month, day}, _} = DateTime.to_erl(post.datetime)
        {{year, month, day, post.order}, post}
      end)

    single_posts =
      Enum.map(posts, fn post ->
        {{year, month, day}, _} = DateTime.to_erl(post.datetime)
        {{year, month, day, post.slug}, post}
      end)

    :ets.insert(@post_table, ordered_posts)
    :ets.insert(@single_post_table, single_posts)
    :ok
  end

  @spec insert_page(Models.Page.t()) :: true
  def insert_page(page) do
    :ets.insert(@page_table, {page.slug, page})
  end

  @spec insert_tag_posts(%{optional(String.t()) => Models.Post.t()}) :: true
  def insert_tag_posts(tags) do
    tag_posts =
      Enum.reduce(Map.keys(tags), [], fn tag, acc ->
        Enum.reduce(tags[tag], acc, fn post, inner_acc ->
          {{year, month, day}, _} = DateTime.to_erl(post.datetime)
          [{{tag, year, month, day, post.order}, post} | inner_acc]
        end)
      end)

    :ets.insert(@tag_table, tag_posts)
  end

  @spec get_menu() :: [Models.MenuItem.t()]
  def get_menu() do
    case :ets.match(@menu_table, :"$1") do
      [] -> []
      results -> format_menu(results)
    end
  end

  @spec get_reg_posts(integer(), integer()) :: [Models.Post.t()]
  def get_reg_posts(first, limit) do
    ms =
      fun do
        {_key, post} -> post
      end

    get_post_list(@post_table, ms, first, limit)
  end

  @spec get_tag_posts(String.t(), integer(), integer()) :: [Models.Post.t()]
  def get_tag_posts(tag, first, limit) do
    ms =
      fun do
        {{^tag, _, _, _, _}, post} -> post
      end

    get_post_list(@tag_table, ms, first, limit)
  end

  @spec get_year_posts(integer(), integer(), integer()) :: [Models.Post.t()]
  def get_year_posts(year, first, limit) do
    ms =
      fun do
        {{^year, _, _, _}, post} -> post
      end

    get_post_list(@post_table, ms, first, limit)
  end

  @spec get_month_posts(integer(), integer(), integer(), integer()) :: [Models.Post.t()]
  def get_month_posts(year, month, first, limit) do
    ms =
      fun do
        {{^year, ^month, _, _}, post} -> post
      end

    get_post_list(@post_table, ms, first, limit)
  end

  @doc """
  Get all months stored in the DB as a list of {year, month} tuples.
  """
  @spec get_all_months() :: [{integer, integer}]
  def get_all_months() do
    ms =
      fun do
        {{year, month, _, _}, _} -> {year, month}
      end

    :ets.select_reverse(@post_table, ms)
    |> Enum.uniq()
  end

  @doc """
  Get a map of tags and their post counts in the system.
  """
  @spec get_all_tags() :: %{optional(String.t()) => integer}
  def get_all_tags() do
    ms =
      fun do
        {{tag, _, _, _, _}, _} -> tag
      end

    :ets.select(@tag_table, ms)
    |> Enum.reduce(%{}, fn tag, acc ->
      Map.update(acc, tag, 1, fn n -> n + 1 end)
    end)
  end

  @spec get_page(String.t()) :: Models.Page.t() | nil
  def get_page(slug) do
    case :ets.match_object(@page_table, {slug, :"$1"}) do
      [{_, page}] -> page
      _ -> nil
    end
  end

  @spec get_post(integer(), integer(), integer(), String.t()) :: Models.Post.t() | nil
  def get_post(year, month, day, slug) do
    case :ets.match_object(@single_post_table, {{year, month, day, slug}, :"$1"}) do
      [{_, post}] -> post
      _ -> nil
    end
  end

  @spec get_count(:all) :: integer()
  def get_count(:all) do
    get_count(:all, :all)
  end

  @spec get_count(atom, :all | integer | String.t() | {integer, integer}) :: integer()
  def get_count(type, key) do
    get_meta(type, key, 0)
  end

  @spec insert_meta(atom, :all | integer | String.t(), integer | String.t()) :: true
  defp insert_meta(type, key, value) do
    :ets.insert(@meta_table, {{type, key}, value})
  end

  @spec get_meta(atom, :all | integer | String.t() | {integer, integer}, integer | String.t()) ::
          integer | String.t()
  defp get_meta(type, key, default) do
    case :ets.match_object(@meta_table, {{type, key}, :"$1"}) do
      [{{_, _}, value}] -> value
      [] -> default
    end
  end

  # Combine error handling of different post listing functions
  @spec get_post_list(atom, [tuple], integer, integer) :: [Models.Post.t()]
  defp get_post_list(table, matchspec, first, limit) do
    case :ets.select_reverse(table, matchspec, first + limit) do
      :"$end_of_table" ->
        []

      {result, _} ->
        Enum.split(result, first) |> elem(1)
    end
  end

  # Format menu results (convert [{slug, %MenuItem{}}] to %MenuItem{})
  @spec format_menu([[{String.t(), Models.MenuItem.t()}]]) :: [Models.MenuItem.t()]
  defp format_menu(results) do
    for [{_, result}] <- results, do: result
  end
end
