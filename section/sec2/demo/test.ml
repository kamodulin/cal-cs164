open OUnit2
open Tree

let test_max_path : test_ctxt -> unit =
  fun _ ->
    List.iter
      ( fun (input, expected) ->
          assert_equal
            ~printer:show_path
            expected
            (max_path input)
      )
      [ ( Node
          ( Node (Leaf, 13, Leaf)
          , 12
          , Leaf
          )
        , [] (* TODO *)
        )
      ]

let _ =
  run_test_tt_main
    ( "Trees" >:::
        [ "Max path" >:: test_max_path
        ]
    )
