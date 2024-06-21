let parse_lexbuf : Lexing.lexbuf -> Ast.stmt list =
  fun lexbuf ->
    try Parse.main Lex.token lexbuf with
      | Lex.Error s ->
          Printf.eprintf "%s\n" s;
          exit 1

      | Parse.Error ->
          Printf.eprintf
            "Parse error at offset %d: '%s'\n"
            (Lexing.lexeme_start lexbuf)
            (Lexing.lexeme lexbuf);
          exit 2

let parse : string -> Ast.stmt list =
  fun s ->
    s
      |> Lexing.from_string
      |> parse_lexbuf

let parse_file : string -> Ast.stmt list =
  fun file ->
    file
      |> open_in
      |> Lexing.from_channel
      |> parse_lexbuf
