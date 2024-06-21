open Symtab
open Syntax.Ast

let rec interp_expr (env : float symtab) : expr -> float = function
  | Num n ->
      n
  | Var v ->
      Symtab.find v env
  | Log e ->
      log (interp_expr env e)
  | Sin e ->
      sin (interp_expr env e)
  | Cos e ->
      cos (interp_expr env e)
  | Tan e ->
      tan (interp_expr env e)
  | Negate e ->
      -.interp_expr env e
  | Group e ->
    interp_expr env e
  | Plus (e1, e2) ->
      interp_expr env e1 +. interp_expr env e2
  | Minus (e1, e2) ->
      interp_expr env e1 -. interp_expr env e2
  | Times (e1, e2) ->
      interp_expr env e1 *. interp_expr env e2
  | Divide (e1, e2) ->
      interp_expr env e1 /. interp_expr env e2
  | Exp (e1, e2) ->
      interp_expr env e1 ** interp_expr env e2

let interp_stmt (env : float symtab) : stmt -> float symtab * float list =
  function
  | Print e ->
      (env, [interp_expr env e])
  | Assign (x, e) ->
      (Symtab.add x (interp_expr env e) env, [])

let interp_program (program : stmt list) =
  List.fold_left
    (fun (env, l) s ->
      let env, o = interp_stmt env s in
      (env, l @ o))
    (Symtab.empty, []) program
  |> snd

let interp (s : string) = s |> Syntax.Parser.parse |> interp_program
