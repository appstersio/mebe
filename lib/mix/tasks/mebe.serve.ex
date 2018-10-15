defmodule Mix.Tasks.Mebe.Serve do
  use MBU.BuildTask, auto_path: false, create_out_path: false
  import MBU.TaskUtils

  @shortdoc "Start Mebe2 server and frontend development tools"

  @deps ["mebe.clean"]

  task _ do
    frontend_path = Path.join([File.cwd!(), "lib", "web", "frontend"])

    [
      exec(System.find_executable("bsb"), ["-w"], name: "ocaml", cd: frontend_path),
      exec(System.find_executable("node"), ["fuse"], name: "fusebox", cd: frontend_path),
      exec(System.find_executable("mix"), ["run", "--no-halt"])
    ]
    |> listen(watch: true)
  end
end
