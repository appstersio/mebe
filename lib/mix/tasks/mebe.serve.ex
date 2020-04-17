defmodule Mix.Tasks.Mebe.Serve do
  use MBU.BuildTask, auto_path: false, create_out_path: false
  import MBU.TaskUtils

  @shortdoc "Start Mebe2 server and frontend development tools"

  @deps ["mebe.build.frontend"]

  task _ do
    [
      watch(
        "Frontend TS",
        Path.join([File.cwd!(), "lib", "web", "frontend", "src"]),
        Mix.Tasks.Mebe.Build.Frontend
      ),
      watch(
        "Frontend assets",
        Path.join([File.cwd!(), "lib", "web", "frontend", "assets"]),
        Mix.Tasks.Mebe.Build.Frontend
      ),
      exec(System.find_executable("mix"), ["run", "--no-halt"])
    ]
    |> listen(watch: true)
  end
end
