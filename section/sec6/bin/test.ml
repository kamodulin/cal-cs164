module Difftest = Shared.Difftest.Make(Section_infra.I)
let () = Difftest.run ()