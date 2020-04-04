defmodule Mebe2.Web.Server do
  @files Raxx.Static.setup(source: Path.expand("priv/static"))

  def child_spec(server_options) do
    {:ok, port} = Keyword.fetch(server_options, :port)

    %{
      id: {__MODULE__, port},
      start: {__MODULE__, :start_link, [server_options]},
      type: :supervisor
    }
  end

  def init(init_arg) do
    {:ok, init_arg}
  end

  def start_link(server_options) do
    stack =
      Raxx.Stack.new(
        [
          {Raxx.Static, @files},
          {Mebe2.Web.Middleware.RequestTime, []},
          {Mebe2.Web.Middleware.Archives, []}
        ],
        {Mebe2.Web.Router, []}
      )

    Ace.HTTP.Service.start_link(stack, server_options)
  end
end
