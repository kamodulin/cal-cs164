open Util
open S_exp

type directions = Left | Right | Down | Up

let dir_to_string d =
  match d with Left -> "L" | Right -> "R" | Down -> "D" | Up -> "U"

let get_relative_direction d =
  match d with
  | Left -> "to the left"
  | Right -> "to the right"
  | Down -> "below"
  | Up -> "above"

type path = directions list

let rec get_coordinates (p : path) : int * int =
  match p with
  | [] -> (0, 0)
  | Left :: ps -> (
      match get_coordinates ps with 0, y -> (0, y) | x, y -> (x - 1, y))
  | Right :: ps ->
      let x, y = get_coordinates ps in
      (x + 1, y)
  | Down :: ps ->
      let x, y = get_coordinates ps in
      (x, y + 1)
  | Up :: ps -> (
      match get_coordinates ps with x, 0 -> (x, 0) | x, y -> (x, y - 1))

let bfs (exp : s_exp) (num : int) : s_exp option =
  let q : s_exp Queue.t = Queue.create () in
  let n : int ref = ref num in
  Queue.push exp q;
  while !n > 0 && not (Queue.is_empty q) do
    n := !n - 1;
    match Queue.pop q with
    | Lst xs -> List.iter (fun x -> Queue.push x q) xs
    | _ -> ()
  done;
  Queue.take_opt q

let read_expr e =
  match e with
  | Lst (Sym f :: args) ->
      Printf.sprintf "%s function call with %d inputs\n" f (List.length args)
  | Sym f -> f
  | Num n -> string_of_int n
  | _ -> "Malformed s-expression\n"

let rec get_error (defns : defn list) (body : s_exp) (p : path) : string =
  match p with
  | [] -> "Empty program\n"
  | x :: xs ->
      Printf.sprintf "No expression %s of %s" (get_relative_direction x)
        (read_position defns body xs)

and read_position (defns : defn list) (body : s_exp) (path : path) : string =
  let n, d = get_coordinates path in
  let _ = Printf.printf "Coordinates: (%d,%d)\n" n d in
  match List.nth_opt defns n with
  | Some defn -> (
      match d with
      (* Task 1: Return an English description of AST nodes of depth 0,1,2 for definitions. See the readme for an example *)
      | 0 -> "Not Implemented"
      | 1 -> Printf.sprintf "%s\n" defn.name
      | 2 -> "Not Implemented"
      (* Task 2: Return the argument name at depth d*)
      | _ when d - 3 < List.length defn.args -> "Not Implemented"
      (* Task 3: Search the definition body using `bfs` for the expression at the right depth.
         Remember that our bfs search starts at depth 0, so d must be offset!
         Use `read_exp` to convert an s_exp into a string*)
      | _ -> "Not Implemented")
  | None when n = List.length defns ->
      if d = 0 then Printf.sprintf "The body of the program\n"
        (* Task 4: Using the same logic as Task 3, search the program body for the expression at the right depth,
           then convert it to a string using 'read_exp' *)
      else ""
  | _ -> get_error defns body path

let navigate_to (defns : defn list) (body : s_exp) (p : path) : unit =
  let text = read_position defns body p in
  Printf.printf "\"%s\"" text

(* Our top level function to handle input and store our running list of input commands *)
let navigate (program : string) : unit =
  let defns, body = parse_many program |> defns_and_body in
  let input = ref (read_int_opt ()) in
  let path = ref [] in
  while !input <> Some 6 do
    (match !input with
    | Some 1 ->
        path := Up :: !path;
        navigate_to defns body !path
    | Some 2 ->
        path := Down :: !path;
        navigate_to defns body !path
    | Some 3 ->
        path := Left :: !path;
        navigate_to defns body !path
    | Some 4 ->
        path := Right :: !path;
        navigate_to defns body !path
    | Some 5 -> navigate_to defns body !path
    | _ -> Printf.sprintf "Bad Input" |> ignore);
    input := read_int_opt ()
  done
