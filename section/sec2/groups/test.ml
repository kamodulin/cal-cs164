open OUnit2
open Buggy

let sort : int list -> int list =
  List.sort Int.compare
