(******************************************************************************)
(* List construction and elimination: tests *)

open OUnit2
open Exercises

let string_of_int_list l =
  "[ " ^ String.concat "; " (List.map string_of_int l) ^ " ]"

let assert_int_list_equal l1 l2 = assert_equal ~printer:string_of_int_list l1 l2

let test_list =
  "test_list"
  >::: [
    ("test1" >:: fun _ -> assert_int_list_equal [ 1; 2; 3; 4; 5 ] l1);
    ("test2" >:: fun _ -> assert_int_list_equal [ 1; 2; 3; 4; 5 ] l2);
    ("test3" >:: fun _ -> assert_int_list_equal [ 1; 2; 3; 4; 5 ] l3);
  ]

let test_match =
  "match list"
  >::: [
    "starts_with_berkeley"
    >::: [
      ( "" >:: fun _ ->
            assert_bool "[] is not starting with 'berkeley'"
              (not (starts_with_berkeley [])) );
      ( "" >:: fun _ ->
            assert_bool
              "[ \"compilers\" ] does not start with \"berkeley\""
              (not (starts_with_berkeley [ "compilers" ])) );
      ( "" >:: fun _ ->
            assert_bool
              "[ \"berkeley\"; \"compilers\" ] starts with \"berkeley\""
              (starts_with_berkeley [ "berkeley"; "compilers" ]) );
      ( "" >:: fun _ ->
            assert_bool
              "[ \"university of california\"; \"berkeley\" ] does not start with \"berkeley\""
              (not (starts_with_berkeley [ "university of california"; "berkeley" ])) );
    ];
    "two_or_four"
    >::: [
      ( "" >:: fun _ ->
            assert_bool "[] has no elements" (not (two_or_four [])) );
      ( "" >:: fun _ ->
            assert_bool "[42] has 1 element" (not (two_or_four [ 42 ])) );
      ( "" >:: fun _ ->
            assert_bool "[4;3] has 2 elements" (two_or_four [ 4; 3 ]) );
      ( "" >:: fun _ ->
            assert_bool "[4;3;2] has 3 elements"
              (not (two_or_four [ 4; 3; 2 ])) );
      ( "" >:: fun _ ->
            assert_bool "[4;3;2;1] has 4 elements"
              (two_or_four [ 4; 3; 2; 1 ]) );
    ];
    "first_two_equal"
    >::: [
      ( "" >:: fun _ ->
            assert_bool "first_two_equal [] should be false"
              (not (first_two_equal [])) );
      ( "" >:: fun _ ->
            assert_bool "first_two_equal [ 42 ] should be false"
              (not (first_two_equal [ 42 ])) );
      ( "" >:: fun _ ->
            assert_bool "first_two_equal [ 42; 42 ] should be true" (first_two_equal [ 42; 42 ])
      );
      ( "" >:: fun _ ->
            assert_bool
              "first_two_equal [ \"apple\"; \"orange\" ] should be false"
              (not (first_two_equal [ "apple"; "orange" ])) );
      ( "" >:: fun _ ->
            assert_bool "first_two_equal [ 2; 2; 3 ] should be true"
              (first_two_equal [ 2; 2; 3 ]) );
    ];
  ]

let suite = "suite" >::: [ test_list; test_match ]

let () = run_test_tt_main suite
