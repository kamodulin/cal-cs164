open Printf
open Util
open S_exp
open Shared
open Error

(** a [value]  is the runtime value of an expression *)
type value = Num of int | Bool of bool | Pair of (value * value) | Nil

type environment = value Symtab.symtab

let input_channel = ref stdin
let output_channel = ref stdout

let top_env () : environment =
  Symtab.empty
  |> Symtab.add "true" (Bool true)
  |> Symtab.add "false" (Bool false)

(** [display_value v] returns a string representation of the runtime value [v] *)
let rec display_value = function
  | Num x -> sprintf "%d" x
  | Bool b -> if b then "true" else "false"
  | Pair (v1, v2) ->
      sprintf "(pair %s %s)" (display_value v1) (display_value v2)
  | Nil -> "()"

let interp_0ary_primitive prim =
  match prim with
  | "read-num" -> Some (Num (input_line !input_channel |> int_of_string))
  | "newline" ->
      output_string !output_channel "\n";
      Some (Bool true)
  | _ -> None

(** [interp_unary_primitive prim arg] tries to evaluate the primitive operation
   named by [prim] on the argument [arg]. If the operation is ill-typed, or if
   [prim] does not refer to a valid primitive operation, it returns None.*)
let interp_unary_primitive prim arg =
  match (prim, arg) with
  | "add1", Num x -> Some (Num (x + 1))
  | "sub1", Num x -> Some (Num (x - 1))
  | "zero?", Num 0 -> Some (Bool true)
  | "zero?", _ -> Some (Bool false)
  | "num?", Num _ -> Some (Bool true)
  | "num?", _ -> Some (Bool false)
  | "not", Bool false -> Some (Bool true)
  | "not", _ -> Some (Bool false)
  | "pair?", Pair _ -> Some (Bool true)
  | "pair?", _ -> Some (Bool false)
  | "left", Pair (v, _) -> Some v
  | "right", Pair (_, v) -> Some v
  | "empty?", Nil -> Some (Bool true)
  | "empty?", _ -> Some (Bool false)
  | "print", v ->
      v |> display_value |> output_string !output_channel;
      Some (Bool true)
  | _ -> None

(** [interp_binary_primitive prim arg1 arg2] tries to evaluate the primitive
   operation named by [prim] on the arguments [arg] and [arg2]. If the operation
   is ill-typed, or if [prim] does not refer to a valid primitive operation, it
   returns None.*)
let interp_binary_primitive prim arg1 arg2 =
  match (prim, arg1, arg2) with
  | "+", Num x1, Num x2 -> Some (Num (x1 + x2))
  | "-", Num x1, Num x2 -> Some (Num (x1 - x2))
  | "=", Num x1, Num x2 -> Some (Bool (x1 = x2))
  | "<", Num x1, Num x2 -> Some (Bool (x1 < x2))
  | "pair", v1, v2 -> Some (Pair (v1, v2))
  | _ -> None

let rec list_of_lst e (lst : value) : value list =
  match lst with
  | Nil -> []
  | Pair (v1, v2) -> v1 :: list_of_lst e v2
  | _ -> raise (Stuck e)

let rec lst_of_list = function [] -> Nil | v :: vs -> Pair (v, lst_of_list vs)

let rec interp_expr (defns : defn list) (env : environment) : s_exp -> value =
  function
  | Num x -> Num x
  | Sym var as e -> (
      match Symtab.find_opt var env with
      | Some value -> value
      | None -> raise (Stuck e))
  | Lst [] -> Nil
  | Lst [ Sym "let"; Lst [ Lst [ Sym var; exp ] ]; body ] ->
      let env = env |> Symtab.add var (interp_expr defns env exp) in
      interp_expr defns env body
  | Lst [ Sym "if"; test_exp; then_exp; else_exp ] ->
      if interp_expr defns env test_exp <> Bool false then
        interp_expr defns env then_exp
      else interp_expr defns env else_exp
  | Lst (Sym "do" :: exps) when List.length exps > 0 ->
      exps |> List.rev_map (interp_expr defns env) |> List.hd
  | Lst [ Sym "apply"; Sym f; args_list ] as e when is_defn defns f -> (
      let args = list_of_lst e (interp_expr defns env args_list) in
      let defn = get_defn defns f in
      match defn.rest with
      | None when List.length args = List.length defn.args ->
          let fenv =
            args |> List.combine defn.args |> Symtab.of_list
            |> Symtab.union (fun _ _a b -> Some b) (top_env ())
          in
          interp_expr defns fenv defn.body
      | Some rest_name when List.length args >= List.length defn.args ->
          let args, rest = List.partition_at (List.length defn.args) args in
          let fenv =
            args |> List.combine defn.args |> Symtab.of_list
            |> Symtab.add rest_name (lst_of_list rest)
            |> Symtab.union (fun _ _a b -> Some b) (top_env ())
          in
          interp_expr defns fenv defn.body
      | _ -> raise (Stuck e))
  | Lst (Sym f :: args) as e when is_defn defns f -> (
      let defn = get_defn defns f in
      match defn.rest with
      | None when List.length args = List.length defn.args ->
          let fenv =
            args
            |> List.map (interp_expr defns env)
            |> List.combine defn.args |> Symtab.of_list
            |> Symtab.union (fun _ _a b -> Some b) (top_env ())
          in
          interp_expr defns fenv defn.body
      | Some rest_name when List.length args >= List.length defn.args ->
          let args = List.map (interp_expr defns env) args in
          let args, rest = List.partition_at (List.length defn.args) args in
          let fenv =
            args |> List.combine defn.args |> Symtab.of_list
            |> Symtab.add rest_name (lst_of_list rest)
            |> Symtab.union (fun _ _a b -> Some b) (top_env ())
          in
          interp_expr defns fenv defn.body
      | _ -> raise (Stuck e))
  | Lst [ Sym f ] as e -> (
      match interp_0ary_primitive f with Some v -> v | None -> raise (Stuck e))
  | Lst [ Sym f; arg ] as e -> (
      match interp_unary_primitive f (interp_expr defns env arg) with
      | Some v -> v
      | None -> raise (Stuck e))
  | Lst [ Sym f; arg1; arg2 ] as e -> (
      match
        let v1 = interp_expr defns env arg1 in
        let v2 = interp_expr defns env arg2 in
        interp_binary_primitive f v1 v2
      with
      | Some v -> v
      | None -> raise (Stuck e))
  | e -> raise (Stuck e)

(** [interp e] evaluates the s_expression [e] using [interp_expr], reading input
   from stdin and writing output to stdout. *)
let interp (exps : s_exp list) =
  let defns, body = defns_and_body exps in
  interp_expr defns (top_env ()) body |> ignore

(** [interp_io e input] evaluates the s_expression [e] using [interp_expr],
   reading input from the string [input] and returning the output as a
   string. *)
let interp_io (es : s_exp list) input =
  let input_pipe_ex, input_pipe_en = Unix.pipe () in
  let output_pipe_ex, output_pipe_en = Unix.pipe () in
  input_channel := Unix.in_channel_of_descr input_pipe_ex;
  set_binary_mode_in !input_channel false;
  output_channel := Unix.out_channel_of_descr output_pipe_en;
  set_binary_mode_out !output_channel false;
  let write_input_channel = Unix.out_channel_of_descr input_pipe_en in
  set_binary_mode_out write_input_channel false;
  let read_output_channel = Unix.in_channel_of_descr output_pipe_ex in
  set_binary_mode_in read_output_channel false;
  output_string write_input_channel input;
  close_out write_input_channel;
  interp es;
  close_out !output_channel;
  let r = input_all read_output_channel in
  input_channel := stdin;
  output_channel := stdout;
  r
