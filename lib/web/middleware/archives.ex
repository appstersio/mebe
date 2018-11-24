defmodule Mebe2.Web.Middleware.Archives do
  require Logger

  @month_archives_key :mebe2_month_archives
  @tag_archives_key :mebe2_tag_archives

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
