module Cli =  Shared.Cli.Make(Section_infra.I)
let () = Cli.compile ()