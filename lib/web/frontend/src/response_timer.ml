let get_cookie_value: string -> string = [%raw fun cookie_name -> {|
  var b = document.cookie.match('(^|;)\\s*' + cookie_name + '\\s*=\\s*([^;]+)');
  return b ? b.pop() : '';
|}]

let render_timer_text: (string -> string) -> string -> unit = [%raw fun get_text cookie_name -> {|
  var tag = document.getElementById('request-timer');
  tag.innerText = get_text(cookie_name);
|}]

let format_time time = match float_of_int (int_of_string time) with
  | t when t >= 1000000.0 -> (t /. 1000000.0, "s")
  | t when t >= 1000.0 -> (t /. 1000.0, "ms")
  | t -> (t, {js|µs|js})

let get_formatted cookie_name =
  let t, u = format_time (get_cookie_value cookie_name) in
    let rounded_t = match t with
      | r when float_of_int (int_of_float r) == t -> Js_float.toFixedWithPrecision t ~digits:0
      | _ -> Js_float.toFixedWithPrecision t ~digits:2 in
        {j| · Rendered in $rounded_t $u|j}

let set_timer_value () =
  render_timer_text get_formatted "mebe2-request-timer"
