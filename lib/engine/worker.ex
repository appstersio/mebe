defmodule Mebe2.Engine.Worker do
  @moduledoc """
  This worker initializes the post database and keeps it alive while the server is running.
  """
  use GenServer
  require Logger

  alias Mebe2.Engine.{Crawler, DB, MenuParser}

  def start_link(opts \\ []) do
    GenServer.start_link(__MODULE__, :ok, opts)
  end

  @spec init(:ok) :: {:ok, nil}
  def init(:ok) do
    load_db()
    {:ok, nil}
  end

  def handle_call(:refresh, _from, nil) do
    refresh_db()
    {:reply, :ok, nil}
  end

  @spec refresh_db() :: :ok
  def refresh_db() do
    Logger.info("Destroying database…")
    :ok = DB.destroy()
    Logger.info("Reloading database…")
    :ok = load_db()
    Logger.info("Update done!")

    :ok
  end

  @doc """
  Initialize the database by crawling the configured path and parsing data to the DB.
  """
  @spec load_db() :: :ok
  def load_db() do
    data_path = Mebe2.get_conf(:data_path)

    Logger.info("Loading menu from '#{data_path}/menu'…")

    menu = MenuParser.parse(data_path)

    Logger.info("Loading post database from '#{data_path}'…")

    %{
      pages: pages,
      posts: posts,
      tags: tags,
      years: years,
      months: months
    } = Crawler.crawl(data_path)

    Logger.info("Loaded #{Enum.count(pages)} pages and #{Enum.count(posts)} posts.")

    DB.init()

    DB.insert_menu(menu)
    DB.insert_posts(posts)
    DB.insert_count(:all, Enum.count(posts))

    Enum.each(Map.keys(pages), fn page -> DB.insert_page(pages[page]) end)

    DB.insert_tag_posts(tags)
    Enum.each(Map.keys(tags), fn tag -> DB.insert_count(:tag, tag, Enum.count(tags[tag])) end)

    # For years and months, only insert the counts (the data can be fetched from main posts table)
    Enum.each(Map.keys(years), fn year ->
      DB.insert_count(:year, year, Enum.count(years[year]))
    end)

    Enum.each(Map.keys(months), fn month ->
      DB.insert_count(:month, month, Enum.count(months[month]))
    end)

    DB.get_all_months() |> DB.insert_archives(:months)
    DB.get_all_tags() |> DB.insert_archives(:tags)

    Logger.info("Posts loaded.")

    :ok
  end
end
