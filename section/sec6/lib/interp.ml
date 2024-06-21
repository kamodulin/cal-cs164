open Printf
open S_exp

(** A [value] is the runtime value of an expression.  *)
type value = Num of int | Bool of bool | Ref of value ref

type environment = value Symtab.symtab

let top_env : environment =
  Symtab.empty
  |> Symtab.add "true" (Bool true)
  |> Symtab.add "false" (Bool false)

(** [display_value v] returns a string representation of the runtime value
    [v]. *)
let rec display_value : value -> string =
 fun v ->
  match v with
  | Num x ->
      sprintf "%d" x
  | Bool b ->
      if b then "true" else "false"
  | Ref r ->
      Printf.sprintf "(ref %s)" (display_value !r)

(** [interp_unary_primitive prim arg] tries to evaluate the primitive operation
    named by [prim] on the argument [arg]. If the operation is ill-typed, or if
    [prim] does not refer to a valid primitive operation, it returns [None]. *)
let interp_unary_primitive : string -> value -> value option =
 fun prim arg ->
  match (prim, arg) with
  | "add1", Num x ->
      Some (Num (x + 1))
  | "sub1", Num x ->
      Some (Num (x - 1))
  | "zero?", Num 0 ->
      Some (Bool true)
  | "zero?", _ ->
      Some (Bool false)
  | "num?", Num _ ->
      Some (Bool true)
  | "num?", _ ->
      Some (Bool false)
  | "not", Bool false ->
      Some (Bool true)
  | "not", _ ->
      Some (Bool false)
  (* Task 2.1 and 2.2: Implement ref and deref here *)
  | _ ->
      None

(** [interp_binary_primitive prim arg1 arg2] tries to evaluate the primitive
    operation named by [prim] on the arguments [arg1] and [arg2]. If the
    operation is ill-typed, or if [prim] does not refer to a valid primitive
    operation, it returns [None]. *)
let interp_binary_primitive : string -> value -> value -> value option =
 fun prim arg1 arg2 ->
  match (prim, arg1, arg2) with
  | "+", Num x1, Num x2 ->
      Some (Num (x1 + x2))
  | "-", Num x1, Num x2 ->
      Some (Num (x1 - x2))
  | "=", Num x1, Num x2 ->
      Some (Bool (x1 = x2))
  | "<", Num x1, Num x2 ->
      Some (Bool (x1 < x2))
  (* Task 2.3: Implement set-ref here. *)
  | _ ->
      None

(** [interp_expr e] tries to evaluate the s-expression [e], producing a
    value. If [e] isn't a valid expression, it raises an error. *)
let rec interp_expr : environment -> s_exp -> value =
 fun env e ->
  match e with
  | Num x ->
      Num x
  | Sym var -> (
    match Symtab.find_opt var env with
    | Some value ->
        value
    | None ->
        raise (Error.Stuck e) )
  | Lst [Sym "let"; Lst [Lst [Sym var; exp]]; body] ->
      let env = env |> Symtab.add var (interp_expr env exp) in
      interp_expr env body
  | Lst [Sym "if"; test_exp; then_exp; else_exp] ->
      if interp_expr env test_exp <> Bool false then interp_expr env then_exp
      else interp_expr env else_exp
  | Lst (Sym "do" :: exps) when List.length exps > 0 ->
      exps |> List.rev_map (interp_expr env) |> List.hd
  | Lst [Sym f; arg] -> (
    match interp_unary_primitive f (interp_expr env arg) with
    | Some v ->
        v
    | None ->
        raise (Error.Stuck e) )
  | Lst [Sym f; arg1; arg2] -> (
    match
      interp_binary_primitive f (interp_expr env arg1) (interp_expr env arg2)
    with
    | Some v ->
        v
    | None ->
        raise (Error.Stuck e) )
  | _ ->
      raise (Error.Stuck e)

(** [interp e] evaluates the s-expression [e] using [interp_expr], then formats
    the result as a string. *)
let interp : s_exp -> string =
 fun e -> e |> interp_expr top_env |> display_value
