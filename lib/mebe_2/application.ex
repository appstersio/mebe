defmodule Mebe2.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  def start(_type, _args) do
    port = Mebe2.get_conf(:port)

    case Code.ensure_loaded(ExSync) do
      {:module, ExSync = mod} ->
        mod.start()

      {:error, _} ->
        :ok
    end

    # List all child processes to be supervised
    children = [
      Mebe2.Engine.Worker.child_spec(name: Mebe2.Engine.Worker),
      {Mebe2.Web.Server, [port: port, cleartext: true]}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Mebe2.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
