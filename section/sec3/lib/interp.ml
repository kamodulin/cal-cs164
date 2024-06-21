open Printf
open S_exp

(** a [value]  is the runtime value of an expression *)
type value = Num of int | Bool of bool

(** [display_value v] returns a string representation of the runtime value [v] *)
let display_value = function
  | Num x ->
      sprintf "%d" x
  | Bool b ->
      if b then "true" else "false"

(** [interp_primitive prim arg] tries to evaluate the primitive operation named
   by [prim] on the argument [arg]. If the operation is ill-typed, or if [prim]
   does not refer to a valid primitive operation, it returns None.*)
let interp_primitive prim arg =
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
  | _ ->
      None

(** [interp_expr e] tries to evaluate the s_expression [e], producing a
   value. If [e] isn't a valid expression, it raises an error. *)
let rec interp_expr : s_exp -> value = function
  | Num x ->
      Num x
  | Sym "true" ->
      Bool true
  | Sym "false" ->
      Bool false
  | Lst [Sym f; arg] as e -> (
    match interp_primitive f (interp_expr arg) with
    | Some v ->
        v
    | None ->
        raise (Error.Stuck e) )
  | e ->
      raise (Error.Stuck e)

(** [interp e] evaluates the s_expression [e] using [interp_expr], then formats
   the result as a string. *)
let interp e = interp_expr e |> display_value
