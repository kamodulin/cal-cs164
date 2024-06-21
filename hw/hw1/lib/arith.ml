open S_exp

(******************************************************************************)
(* Task 1 *)

(* Task 1.1 *)

let string_of_s_exp : s_exp -> string =
  fun exp ->
    failwith "TODO"

(******************************************************************************)
(* Task 2 *)

(* Task 2.1 is found in `test/test_arith.ml` *)

(* Task 2.2 *)

let is_bin : s_exp -> bool =
  fun exp ->
    failwith "TODO"

(* Task 2.3 is found in `test/test_arith.ml` *)

(* Task 2.4 *)

exception Stuck of s_exp

let interp_bin : s_exp -> int =
  fun exp ->
    failwith "TODO"

(* Task 2.5 is found in `test/test_arith.ml` *)

(* Task 2.6 *)

type instr
  = Push of int
  | Add
  | Mul

type stack =
  int list

exception ShortStack of stack

let interp_instr : stack -> instr -> stack =
  fun stack instr ->
    failwith "TODO"

let interp_program : instr list -> int =
  fun instrs ->
    failwith "TODO"

(* Task 2.7 is found in `test/test_arith.ml` *)

(* Task 2.8 *)

let compile_bin : s_exp -> instr list =
  fun exp ->
    failwith "TODO"

(* Task 2.9 is found in `test/test_arith.ml` *)

(******************************************************************************)
(* Task 3 *)

(* Task 3.1 *)

let desugar_variadic : s_exp -> s_exp =
  fun exp ->
    failwith "TODO"

(* Task 3.2 *)

let interp_variadic : s_exp -> int =
  fun exp ->
    failwith "TODO"

(* Task 3.3 is found in `test/test_arith.ml` *)
