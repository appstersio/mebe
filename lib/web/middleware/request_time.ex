defmodule Mebe2.Web.Middleware.RequestTime do
  require Logger

  @timer_key :mebe2_request_started
  @timer_cookie_name "mebe2-request-timer"

  defmacro __using__(_opts) do
    quote do
      @before_compile unquote(__MODULE__)
    end
  end

  defmacro __before_compile__(_env) do
    quote do
      defoverridable Raxx.Server

      @impl Raxx.Server
      def handle_head(head, config) do
        unquote(__MODULE__).put_response_timer()

        super(head, config)
        |> unquote(__MODULE__).process_response()
      end
    end
  end

  @doc false
  def process_response(response = %Raxx.Response{}) do
    add_timer_cookie(response)
  end

  def process_response({[response = %Raxx.Response{} | parts], state}) do
    {[add_timer_cookie(response) | parts], state}
  end

  def process_response(reaction) do
    reaction
  end

  @spec put_response_timer() :: :ok
  def put_response_timer() do
    Process.put(@timer_key, get_time())
    :ok
  end

  @spec add_timer_cookie(Raxx.Response.t()) :: Raxx.Response.t()
  def add_timer_cookie(%Raxx.Response{} = response) do
    old_time = Process.get(@timer_key)
    diff = get_time() - old_time

    Raxx.set_header(response, "set-cookie", "#{@timer_cookie_name}=#{diff}; Max-Age=60")
  end

  defp get_time(), do: :erlang.monotonic_time(:micro_seconds)
end
