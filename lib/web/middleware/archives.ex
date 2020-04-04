defmodule Mebe2.Web.Middleware.Archives do
  @behaviour Raxx.Middleware

  @month_archives_key :mebe2_month_archives
  @tag_archives_key :mebe2_tag_archives

  @impl true
  def process_head(request, state, inner_server) do
    put_archives()
    {parts, inner_server} = Raxx.Server.handle_head(inner_server, request)
    {parts, state, inner_server}
  end

  @impl true
  def process_tail(tail, state, inner_server) do
    {parts, inner_server} = Raxx.Server.handle_tail(inner_server, tail)
    {parts, state, inner_server}
  end

  @impl true
  def process_data(data, state, inner_server) do
    {parts, inner_server} = Raxx.Server.handle_data(inner_server, data)
    {parts, state, inner_server}
  end

  @impl true
  def process_info(info, state, inner_server) do
    {parts, inner_server} = Raxx.Server.handle_info(inner_server, info)
    {parts, state, inner_server}
  end

  @doc """
  Put yearly and monthly archives into the process storage of the current process.
  """
  @spec put_archives() :: :ok
  def put_archives() do
    months = Mebe2.Engine.DB.get_archives(:months)
    Process.put(@month_archives_key, months)

    tags = Mebe2.Engine.DB.get_archives(:tags)
    Process.put(@tag_archives_key, tags)
    :ok
  end

  @doc """
  Get list of tuples {year, month} that have at least one post.
  """
  @spec get_month_archives() :: [{integer, integer}]
  def get_month_archives() do
    Process.get(@month_archives_key, [])
  end

  @doc """
  Get map of tags (keys) and their post amounts (values).
  """
  @spec get_tag_archives() :: %{optional(String.t()) => integer}
  def get_tag_archives() do
    Process.get(@tag_archives_key, %{})
  end
end
