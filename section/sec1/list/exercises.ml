(******************************************************************************)
(* List construction and elimination: exercises *)

(* Exercise: construct a list that has the integers 1 through 5 in it. Use the
 * square bracket notation for lists.
 *)
let l1 : int list =
  []

(* Exercise: construct the same list, but do not use the square bracket
 * notation.  Instead use `::` and `[]`.
 *
 * Note that ocamlformat may rewrite this expression to use the square bracket
 * notation. That's totally fine!
 *)
let l2 : int list =
  []

(* Exercise: construct the same list again. This time, the following expression
 * must appear in your answer: `[2;3;4]`. Use the @ operator, and do not use
 * `::`.
 *)
let l3 : int list =
  []

(* Exercise: patterns
 *
 * Using pattern matching, write three functions, one for each of the following
 * properties. Your functions should return true if the input list has the
 * property and false otherwise.
 *  - The list's first element is "berkeley"
 *  - The list has exactly two or four elements; do not use the length function.
 *  - The first two elements of the list are equal.
 * Also give each of these functions type signatures, using each annotation
 * style at least once.
 *)

let starts_with_berkeley lst =
  begin match lst with
    | _ -> false
  end

let two_or_four lst =
  begin match lst with
    | _ -> false
  end

let first_two_equal lst =
  begin match lst with
    | _ -> false
  end

(* We will write more list functions in the next section. *)
