defmodule Mix.Tasks.Mebe.Build.Frontend do
  use MBU.BuildTask, auto_path: false, create_out_path: true
  import MBU.TaskUtils

  @shortdoc "Build Mebe2 frontend"

  @deps ["mebe.clean"]

  def out_path(), do: File.cwd!() |> Path.join("priv") |> Path.join("static")

  task _ do
    frontend_path = Path.join([File.cwd!(), "lib", "web", "frontend"])
    exec(System.find_executable("bash"), ["build.sh"], cd: frontend_path) |> listen()
  end
end
