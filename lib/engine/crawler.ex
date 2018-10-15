defmodule Mebe2.Engine.Crawler do
  @moduledoc """
  The crawler goes through the specified directory, opening and parsing all the matching files
  inside concurrently.
  """
  require Logger

  alias Mebe2.Engine.{Parser, Utils, SlugUtils}
  alias Mebe2.Engine.Models.{Page, Post}

  def crawl(path) do
    get_files(path)
    |> Enum.map(fn file -> Task.async(__MODULE__, :parse, [file]) end)
    |> handle_responses()
    |> construct_archives()
  end

  def get_files(path) do
    path = path <> "/**/*.md"
    Logger.info("Searching files using '#{path}' with cwd '#{System.cwd()}'")
    files = Path.wildcard(path)
    Logger.info("Found files:")

    for file <- files do
      Logger.info(file)
    end

    files
  end

  def parse(file) do
    try do
      File.read!(file)
      |> Parser.parse(Path.basename(file))
    rescue
      _ ->
        Logger.error("Could not parse file #{file}. Exception: #{inspect(__STACKTRACE__)}")
        :error
    end
  end

  def handle_responses(tasklist) do
    Enum.map(tasklist, fn task -> Task.await(task) end)
  end

  def construct_archives(datalist) do
    Enum.reduce(
      datalist,
      %{
        pages: %{},
        posts: [],
        years: %{},
        months: %{},
        tags: %{},
        authors: %{},
        author_names: %{}
      },
      fn pagedata, acc ->
        case pagedata do
          # Ignore pages/posts that could not be parsed
          :error ->
            acc

          %Page{} ->
            put_in(acc, [:pages, pagedata.slug], pagedata)

          %Post{} ->
            {{year, month, _}, _} = Calendar.DateTime.to_erl(pagedata.datetime)

            tags =
              Enum.reduce(pagedata.tags, acc.tags, fn tag, tagmap ->
                posts = Map.get(tagmap, tag, [])
                Map.put(tagmap, tag, [pagedata | posts])
              end)

            {authors, author_names} = form_authors(acc, pagedata)

            year_posts = [pagedata | Map.get(acc.years, year, [])]
            month_posts = [pagedata | Map.get(acc.months, {year, month}, [])]

            %{
              acc
              | posts: [pagedata | acc.posts],
                years: Map.put(acc.years, year, year_posts),
                months: Map.put(acc.months, {year, month}, month_posts),
                tags: tags,
                authors: authors,
                author_names: author_names
            }
        end
      end
    )
  end

  defp form_authors(datalist, pagedata) do
    multi_author_mode = Mebe2.get_conf(:multi_author_mode)
    do_form_authors(multi_author_mode, datalist, pagedata)
  end

  defp do_form_authors(false, _, _), do: {%{}, %{}}

  defp do_form_authors(true, %{authors: authors, author_names: author_names}, pagedata) do
    author_name = Utils.get_author(pagedata)
    author_slug = SlugUtils.slugify(author_name)
    author_posts = [pagedata | Map.get(authors, author_slug, [])]
    authors = Map.put(authors, author_slug, author_posts)

    # Authors end up with the name that was in the post with the first matching slug
    author_names = Map.put_new(author_names, author_slug, author_name)

    {authors, author_names}
  end
end
