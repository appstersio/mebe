defmodule Mebe2.Web.Middleware.RequestTime do
  require Logger

  @behaviour Raxx.Middleware

  @timer_key :mebe2_request_started
  @timer_cookie_name "mebe2-request-timer"

  @impl true
  def process_head(request, state, inner_server) do
    put_response_timer()
    {parts, inner_server} = Raxx.Server.handle_head(inner_server, request)
    {parts, state, inner_server}
  end

  @impl true
  def process_tail(tail, state, inner_server) do
    {parts, inner_server} = Raxx.Server.handle_tail(inner_server, tail)
    parts = modify_response_parts(parts, state)
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

  @spec put_response_timer() :: :ok
  def put_response_timer() do
    Process.put(@timer_key, get_time())
    :ok
  end

  defp modify_response_parts(parts, :disengage) do
    parts
  end

  defp modify_response_parts(parts, :engage) do
    Enum.flat_map(parts, &do_handle_response_part(&1))
  end

  defp do_handle_response_part(response = %Raxx.Response{}) do
    [add_timer_cookie(response)]
  end

  @spec add_timer_cookie(Raxx.Response.t()) :: Raxx.Response.t()
  defp add_timer_cookie(%Raxx.Response{} = response) do
    old_time = Process.get(@timer_key)
    diff = get_time() - old_time

    Raxx.set_header(response, "set-cookie", "#{@timer_cookie_name}=#{diff}; Max-Age=60")
  end

  defp get_time(), do: :erlang.monotonic_time(:micro_seconds)
end
