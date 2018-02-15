open Core

type error_desc =
| Typemod of Ocaml_common.Typemod.error
| Typetexp of Ocaml_common.Typetexp.error

type error = {
  desc: error_desc;
  loc: Location.t;
}

let parse src filename =
  let buf = Lexing.from_string src in
  buf.lex_start_p <- { buf.lex_start_p with pos_fname = filename };
  buf.lex_curr_p <- { buf.lex_curr_p with pos_fname = filename };
  Ocaml_common.Parse.use_file buf

let typed_of_parse parsetree =
  let env = Ocaml_common.Env.empty in
  let check = function
  | Parsetree.Ptop_dir(_, _) ->
      failwith "Ignoring directive"
  | Parsetree.Ptop_def(s) ->
      Ocaml_common.Typemod.type_toplevel_phrase env s
      |> ignore
  in
  List.iter parsetree ~f:check

let compile (filename: string) : error option =
  try
    let src = In_channel.read_all filename in
    let parsetree = parse src filename in
    typed_of_parse parsetree;
    None
  with
    | Ocaml_common.Typemod.Error(loc, _, err) ->
        Some({ desc = Typemod(err); loc; })
    | Ocaml_common.Typetexp.Error(loc, _, err) ->
        Some({ desc = Typetexp(err); loc; })
    | ex -> raise ex

let main filename =
  match compile filename with
  | Some(err) -> print_endline "TODO"
  | None -> ()

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
