open Core.Std;;

let read_file (filename : string) : string list =
  In_channel.read_lines filename 

let () = 
  let nargs = Array.length Sys.argv in 
  let n = if nargs > 1 then Sys.argv.(1) else "20" in 
  let fn = Printf.sprintf "../data/graph%s.adj" n in 
  let lines = read_file fn in 
  print_newline (print_int (List.length lines)); 

