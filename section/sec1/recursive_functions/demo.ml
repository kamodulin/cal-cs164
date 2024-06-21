(******************************************************************************)
(* Recursive functions *)

let rec length (l : int list) : int =
  begin match l with
    | [] -> 0
    | x :: xs -> 1 + length xs
  end

let rec length_tail (l : int list) (acc : int) : int =
  begin match l with
    | [] -> acc
    | x :: xs -> length_tail xs (acc + 1)
  end

let rec even n =
  begin match n with
    | 0 -> true
    | x -> odd (x-1)
  end
and odd n =
  begin match n with
    | 0 -> false
    | x -> even (x-1)
  end

let rec fibonacci : int -> int =
  fun n ->
    if n < 3 then
      1
    else
      fibonacci (n - 1) + fibonacci (n - 2)

(* In utop: #trace fibonacci *)
