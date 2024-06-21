(* We assume that each node contains a non-negative integer. *)
type tree
  = Leaf
  | Node of tree * int * tree

type direction
  = Left
  | Right

type path =
  direction list

let show_path : path -> string =
  fun p ->
    let inner =
      begin match p with
        | [] ->
            "empty path"

        | _ ->
            String.concat
              ""
              ( List.map
                  ( fun d ->
                      begin match d with
                        | Left -> "L"
                        | Right -> "R"
                      end
                  )
                  p
              )
      end
    in
    "<" ^ inner ^ ">"

let rec max_path_helper : int -> tree -> path -> (int * path) =
  fun max curr trace -> match curr with
      Leaf -> (max, trace)
    | Node (left, v, right) ->
      let (lm, lmp) = max_path_helper v left (Left::trace) in
      let (rm, rmp) = max_path_helper v right (Right::trace) in
      let (new_max, new_path) = if lm > rm then (lm, lmp) else (rm, rmp) in
      if v = new_max then (v, trace) else (new_max, new_path)

let max_path : tree -> path =
  fun t -> let (_, p) = max_path_helper 0 t [] in List.rev p
