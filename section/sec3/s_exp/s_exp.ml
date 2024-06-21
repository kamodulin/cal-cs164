type s_exp = Exp.t

let show = Exp.show

let parse = Parser.parse

let parse_file = Parser.parse_file

let rec string_of_s_exp : s_exp -> string = function
  | Sym x ->
      x
  | Num n ->
      string_of_int n
  | Lst exps ->
      let exps = exps |> List.map string_of_s_exp in
      "(" ^ String.concat " " exps ^ ")"
  | Chr c -> (
      "#\\"
      ^ match c with '\n' -> "newline" | ' ' -> "space" | _ -> String.make 1 c )
