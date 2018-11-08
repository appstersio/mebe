defmodule Mix.Tasks.Mebe.Build.Frontend do
  use MBU.BuildTask, auto_path: false, create_out_path: false
  import MBU.TaskUtils

  @shortdoc "Build Mebe2 frontend"

  @deps ["mebe.clean"]

  task _ do
    frontend_path = Path.join([File.cwd!(), "lib", "web", "frontend"])

    [
      exec(System.find_executable("bsb"), [], name: "ocaml", cd: frontend_path),
      exec(System.find_executable("node"), ["fuse", "build"], name: "fusebox", cd: frontend_path)
    ]
    |> listen()
  end
end
