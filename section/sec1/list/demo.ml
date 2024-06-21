(*******************************************************************************
 * List construction
 *)

(* There are two kinds of lists: empty ones, and non-empty ones.
 *)

(* `[]` constructs an empty list.
 *)

let empty_list : int list =
  []

(* `e :: es` constructs a non-empty list, where `e` is the first element and
 * `es` are the remaining.
 *)

let non_empty_list : int list =
  42 :: []

(* We can construct longer lists with `[]` and `::`.
 *)

let welcome : string list =
  "Welcome" :: "to" :: "CS 164!" :: []

(* But there is a shorthand!
 *)

let same_welcome_but_with_shorthand : string list =
  [ "Welcome"; "to"; "CS 164!" ]

(* The operator `@` concatenates two lists:
 *)

let _ = assert ([ 2; 3 ] = [ 2 ] @ [ 3 ])
let _ = assert ([ 2; 3 ] = [ 2 ] @ [] @ [ 3 ])

(* `assert` will raise an exception if the condition that you pass to it is
 * `false`.
 *
 * Note: it's very important that we use `=` and not `==` here! You almost NEVER
 * want to use `==` in OCaml! The former is structural equality, whereas the
 * latter is physical equality, which is implementation-dependent.
 *)

(*******************************************************************************
 * List destruction (a.k.a. "elimination")
 *)

(* We have seen how to construct lists. Now it's time to destruct them!
 *)

(* `match` performs a case analysis on lists. The two cases correspond to two
 * list constructors (`[]` and `(::)`).
 *
 * Note that "begin" is a synonym for left paren and "end" is a synonym for
 * right paren; i.e., `begin 1 + 2 end` is the same as `(1 + 2)`. We recommend
 * always putting parentheses around `match` expressions because OCaml has weird
 * parsing behavior for nested non-parenthesized `match` expressions.
 *)

(* Note that we don't need to write types explicitly; they are inferred! *)
let empty lst =
  begin match lst with
    | [] -> true
    | _ :: _ -> false
  end

let _ = assert (empty [])
let _ = assert (not (empty [2; 3]))

(* It's still good practice to start with the type signature of a function,
 * though, and it provides good documentation. Here's the first style of doing
 * so: *)
let head : int list -> int =
  fun lst ->
    begin match lst with
      | [] -> raise (Failure "lst is empty")
      | h :: _ -> h
    end

(* Here's the second style: *)
let tail (lst : int list) : int list =
  begin match lst with
    | [] -> raise (Failure "lst is empty")
    | _ :: t -> t
  end

let _ = assert (head [1; 2; 3] = 1)
let _ = assert (tail [1; 2; 3] = [2; 3])

let the_second_is_zero lst =
  begin match lst with
    | _ :: 0 :: _ -> true
    | _ -> false
  end

let contains_three lst =
  begin match lst with
    | [_; _; _] -> true
    | _ -> false
  end
