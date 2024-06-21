{
  open Parse

  exception Error of string
}

rule token =
  parse
    | [' ' '\t']
        { token lexbuf }
    | ['\n' ';']
        { NEWLINE }
    | '+'
        { PLUS }
    | "print"
        { PRINT }
    | ['0'-'9']+ as i
        { NUMBER (float_of_string i) }
    | eof
        { EOF }
    | _ as c
        { raise
            ( Error
                ( Printf.sprintf
                    "Unexpected character at offset %d: '%c'"
                    (Lexing.lexeme_start lexbuf)
                    c
                )
            )
        }
