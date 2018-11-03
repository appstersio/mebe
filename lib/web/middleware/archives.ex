defmodule Mebe2.Web.Middleware.Archives do
  require Logger

  @archives_key :mebe2_archives

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
        unquote(__MODULE__).put_archives()

        super(head, config)
      end
    end
  end

  @doc """
  Put yearly and monthly archives into the process storage of the current process.
  """
  @spec put_archives() :: :ok
  def put_archives() do
    months = Mebe2.Engine.DB.get_all_months()
    Process.put(@archives_key, months)
    :ok
  end

  @doc """
  Get list of tuples {year, month} that have at least one post.
  """
  @spec get_archives() :: [{integer, integer}]
  def get_archives() do
    Process.get(@archives_key, [])
  end
end
