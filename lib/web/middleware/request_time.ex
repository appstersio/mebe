defmodule Mebe2.Web.Middleware.RequestTime do
  require Logger

  @timer_key :mebe2_request_started

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
      end

      @impl Raxx.Server
      def handle_data(data, config) do
        unquote(__MODULE__).put_response_timer()
        super(data, config)
      end

      @impl Raxx.Server
      def handle_tail(tail, config) do
        unquote(__MODULE__).put_response_timer()
        super(tail, config)
      end

      @impl Raxx.Server
      def handle_info(message, config) do
        unquote(__MODULE__).put_response_timer()
        super(message, config)
      end
    end
  end

  @spec put_response_timer() :: :ok
  def put_response_timer() do
    Process.put(@timer_key, get_time())
    :ok
  end

  @spec get() :: String.t()
  def get() do
    old_time = Process.get(@timer_key)
    diff = get_time() - old_time

    cond do
      diff >= 1_000_000 -> "#{Float.round(diff / 1_000_000, 2)} s"
      diff >= 1_000 -> "#{Float.round(diff / 1_000, 2)} ms"
      true -> "#{diff} µs"
    end
  end

  defp get_time(), do: :erlang.monotonic_time(:micro_seconds)
end
