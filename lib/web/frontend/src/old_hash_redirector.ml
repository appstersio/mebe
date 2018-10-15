(*
 * This script will check old Laine-style hashes when the page has been loaded and redirects
 * to the correct address if such a hash is found.
 * This is done in JS because the hash is not sent to the server.
 *)

type hash_matcher =
  { old_hash : Js.Re.t;
    new_hash : string;
  }

let hash_re = [
  { old_hash = [%re "/^\\#\\!\\/(\\d{4})\\/(\\d\\d)\\/(\\d\\d)\\/(.*)$/"];
    new_hash = "/$1/$2/$3/$4";
  };
  { old_hash = [%re "/^\\#\\!\\/tag\\/([^\\/]+)$/"];
    new_hash = "/tag/$1";
  };
  { old_hash = [%re "/^\\#\\!\\/tag\\/([^\\/]+)(\\/\\d+)$/"];
    new_hash = "/tag/$1/p/$2";
  };
  { old_hash = [%re "/^\\#\\!\\/archives\\/(\\d{4})$/"];
    new_hash = "/archive/$1";
  };
  { old_hash = [%re "/^\\#\\!\\/archives\\/(\\d{4})\\/(\\d\\d)$/"];
    new_hash = "/archive/$1/$2";
  };
  { old_hash = [%re "/^\\#\\!\\/archives\\/(\\d{4})(\\/\\d+)$/"];
    new_hash = "/archive/$1/p/$2";
  };
  { old_hash = [%re "/\\#\\!\\/archives\\/(\\d{4})\\/(\\d\\d)(\\/\\d+)$/"];
    new_hash = "/archive/$1/$2/p/$3";
  };
  { old_hash = [%re "/^\\#\\!\\/(.*)$/"];
    new_hash = "/$1";
  }
]

let rec check_single_hash hash_list current_hash = match hash_list with
  | matcher :: tail ->
    let is_match = Js.Re.test current_hash matcher.old_hash in
      if is_match
        then Some(Js.String.replaceByRe matcher.old_hash matcher.new_hash current_hash)
        else check_single_hash tail current_hash
  | [] -> None

let run_hash_check hash =
  check_single_hash hash_re hash
