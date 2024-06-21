open Syntax.Parser
open Lib.Interp

let command =
  Core.Command.basic ~summary:"Interpret the given file"
    Core.Command.Let_syntax.(
      let%map_open filename =
        anon (maybe ("filename" %: Core.Command.Param.string))
      and expression =
        flag "-e" (optional string) ~doc:"expression to evaluate"
      in
      fun () ->
        try
          match (filename, expression) with
          | Some f, _ ->
              parse_file f |> interp_program |> List.iter (Printf.printf "%f\n")
          | _, Some e ->
              parse e |> interp_program |> List.iter (Printf.printf "%f\n")
          | _ ->
              Printf.eprintf
                "Error: must specify either an expression to evaluate or a file\n"
        with e -> Printf.eprintf "Error: %s\n" (Core.Exn.to_string e))

let () = Command_unix.run ~version:"1.0" command
