defmodule Mix.Tasks.Mebe.Clean do
  use MBU.BuildTask, auto_path: false, create_out_path: false
  require Logger

  @shortdoc "Clean frontend build artifacts"

  task _ do
    static_path = File.cwd!() |> Path.join("priv") |> Path.join("static")
    Logger.debug("Cleaning path #{static_path}...")
    File.rm_rf!(static_path)
  end
end
