open Core

type error = unit

let parse src filename =
  let buf = Lexing.from_string src in
  buf.lex_start_p <- { buf.lex_start_p with pos_fname = filename };
  buf.lex_curr_p <- { buf.lex_curr_p with pos_fname = filename };
  Ocaml_common.Parse.use_file buf

let compile (filename: string) : error option =
  try
    let src = In_channel.read_all filename in
    let parsetree = parse src filename in
    failwith "TODO"
  with
    | ex -> raise ex

let main filename =
  print_endline "TODO"

let () =
  let open Command.Let_syntax in
  Command.basic
    ~summary:"Print OCaml errors prettily"
    [%map_open
      let filename =
        anon ("filename" %: string)
      in
      fun () ->
        main filename
    ]
  |> Command.run
