[%raw {|
  require('./style/index.scss'),
  require('./code_hl.bs.js')
|}]

external window_hash: string = "hash" [@@bs.val][@@bs.scope "window", "location"]

let change_url: (string -> unit) = [%raw fun new_url -> "window.location.href = new_url"]

let run () =
  let new_hash = Old_hash_redirector.run_hash_check window_hash in
    match new_hash with
    | Some h -> change_url h
    | None -> ()

let () = run()
