let rec sort : int list -> int list =
  fun xs ->
    begin match xs with
      | [] ->
          []

      | head :: tail ->
          let left  = List.filter (fun n -> n > head) tail in
          let right = List.filter (fun n -> n < head) tail in
          sort left @ [head] @ sort right
    end
