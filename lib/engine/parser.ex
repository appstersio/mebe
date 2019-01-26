defmodule Mebe2.Engine.Parser do
  @moduledoc """
  This module contains the parser, which parses page data and returns the contents in the correct format.
  """

  alias Mebe2.Engine.Models.{PageData, Page, Post}

  @time_re ~R/(?<hours>\d\d):(?<minutes>\d\d)(?: (?<timezone>.*))?/

  @earmark_opts %Earmark.Options{
    code_class_prefix: "language-"
  }

  def parse(pagedata, filename) do
    split_lines(pagedata)
    |> parse_raw(%PageData{filename: filename})
    |> render_content()
    |> format()
  end

  @spec split_lines(String.t()) :: [String.t()]
  def split_lines(pagedata) do
    String.split(pagedata, ~R/\r?\n/)
  end

  @spec parse_raw([String.t()], PageData.t(), :content | :headers | :title) :: PageData.t()
  def parse_raw(datalines, pagedata \\ %PageData{}, mode \\ :title)

  def parse_raw([title | rest], pagedata, :title) do
    parse_raw(rest, %{pagedata | title: title}, :headers)
  end

  def parse_raw(["" | rest], pagedata, :headers) do
    # Reverse the headers so they appear in the order that they do in the file
    headers = Enum.reverse(pagedata.headers)
    parse_raw(rest, %{pagedata | headers: headers}, :content)
  end

  def parse_raw([header | rest], pagedata, :headers) do
    headers = [header | pagedata.headers]
    parse_raw(rest, %{pagedata | headers: headers}, :headers)
  end

  def parse_raw(content, pagedata, :content) when is_list(content) do
    %{pagedata | content: Enum.join(content, "\n")}
  end

  @spec render_content(PageData.t()) :: PageData.t()
  def render_content(pagedata) do
    %{pagedata | content: Earmark.as_html!(pagedata.content, @earmark_opts)}
  end

  @spec format(PageData.t()) :: Page.t() | Post.t()
  def format(%PageData{
        filename: filename,
        title: title,
        headers: headers,
        content: content
      }) do
    case Regex.run(~R/^(?:(\d{4})-(\d{2})-(\d{2})(?:-(\d{2}))?-)?(.*?).md$/iu, filename) do
      # Pages do not have any date information
      [_, "", "", "", "", slug] ->
        %Page{
          slug: slug,
          title: title,
          content: content,
          extra_headers: parse_headers(headers)
        }

      [_, year, month, day, order, slug] ->
        {tags, extra_headers} = split_tags(headers)
        extra_headers = parse_headers(extra_headers)

        order = format_order(order)

        split_content = Regex.split(~R/<!--\s*SPLIT\s*-->/u, content)

        date_erl = date_to_int_tuple({year, month, day})
        date = Date.from_erl!(date_erl)

        time_header = Map.get(extra_headers, "time", nil)
        {time, tz} = parse_time(time_header)

        datetime = Calendar.DateTime.from_date_and_time_and_zone!(date, time, tz)

        %Post{
          slug: slug,
          title: title,
          datetime: datetime,
          time_given: time_header != nil,
          tags: parse_tags(tags),
          content: content,
          short_content: hd(split_content),
          order: order,
          has_more: Enum.count(split_content) > 1,
          extra_headers: extra_headers
        }
    end
  end

  defp parse_headers(headers) do
    # Parse a list of headers into a string keyed map
    Enum.reduce(headers, %{}, fn header, acc ->
      {key, val} = split_header(header)
      Map.put(acc, key, val)
    end)
  end

  defp split_header(header) do
    # Enforce 2 parts
    [key | [val]] = String.split(header, ":", parts: 2)
    {String.trim(key), String.trim(val)}
  end

  # Split tags from top of headers
  defp split_tags([]), do: {"", []}
  defp split_tags([tags | headers]), do: {tags, headers}

  defp parse_tags(tagline) do
    case String.split(tagline, ~R/,\s*/iu) do
      [""] -> []
      list -> list
    end
  end

  # Parse time data from time header
  defp parse_time(nil), do: form_time(nil)

  defp parse_time(time_header) when is_binary(time_header) do
    with %{"hours" => h, "minutes" => m, "timezone" => tz} <-
           Regex.named_captures(@time_re, time_header) do
      tz =
        if tz == "" do
          Mebe2.get_conf(:time_default_tz)
        else
          tz
        end

      form_time({str_to_int(h), str_to_int(m)}, tz)
    else
      _ -> form_time(nil)
    end
  end

  # Form time and timezone from given time parts
  def form_time(nil) do
    # If not given, time is midnight (RSS feeds require a time)
    {Time.from_erl!({0, 0, 0}), Mebe2.get_conf(:time_default_tz)}
  end

  def form_time({hours, minutes}, tz) do
    {Time.from_erl!({hours, minutes, 0}), tz}
  end

  defp date_to_int_tuple({year, month, day}) do
    {
      str_to_int(year),
      str_to_int(month),
      str_to_int(day)
    }
  end

  defp str_to_int("00"), do: 0

  defp str_to_int(str) when is_binary(str) do
    {int, _} =
      String.trim_leading(str, "0")
      |> Integer.parse()

    int
  end

  defp format_order(""), do: 0
  defp format_order(order), do: str_to_int(order)
end
