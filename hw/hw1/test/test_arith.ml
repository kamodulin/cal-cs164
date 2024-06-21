open OUnit2
open S_exp
open Lib.Arith

(******************************************************************************)
(* Tasks *)

(* Task 2.1 *)

let test_is_bin : test_ctxt -> unit =
  fun _ ->
    failwith "TODO"

(* Task 2.3 *)

let test_interp_bin : test_ctxt -> unit =
  fun _ ->
    failwith "TODO"

(* Task 2.5 *)

let test_interp_instr : test_ctxt -> unit =
  fun _ ->
    failwith "TODO"

let test_interp_program : test_ctxt -> unit =
  fun _ ->
    failwith "TODO"

(* Task 2.7 *)

let test_compile_bin : test_ctxt -> unit =
  fun _ ->
    failwith "TODO"

(* Task 2.9 *)

let test_compile_versus_interp_bin : test_ctxt -> unit =
  fun _ ->
    failwith "TODO"

(* Task 3.3 *)

let test_variadic : test_ctxt -> unit =
  fun _ ->
    failwith "TODO"

(******************************************************************************)
(* Test runner *)

let _ =
  run_test_tt_main
    ( "arith tests" >:::
        [ "is_bin" >:: test_is_bin
        ; "interp_bin" >:: test_interp_bin
        ; "interp_instr" >:: test_interp_instr
        ; "interp_program" >:: test_interp_program
        ; "compile_bin" >:: test_compile_bin
        ; "compiling vs. interpreting" >:: test_compile_versus_interp_bin
        ; "variadic" >:: test_variadic
        ]
    )
