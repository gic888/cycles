open Core.Std;;
open String.Map;;

type graph = string list Core.Std.String.Map.t
type path = string * string * Core.Std.String.Set.t * graph

let read_file (filename : string) : string list =
  In_channel.read_lines filename 

let read_graph (raw_lines: string list) : graph =
  let lines = List.filter raw_lines (fun (s) -> String.length s > 0 && String.get s 0 != '#') in 
  String.Map.of_alist_exn (List.map lines 
    (fun (s) -> let cs = String.split_on_chars s [' '] in (List.hd_exn cs, List.tl_exn cs)))

let sum_list (l: int list) =   match List.reduce l (+) with 
  | Some i -> i
  | None -> 0

let path_continues_to p v =
  let (start, stop, touches, g) = p in 
  (start, v, Set.add touches v, g)

let rec count_cycles_at p v = 
  let (start, stop, touches, g) = p in 
  match v with 
    | x when  x = start -> 1
    | x when x > start && not (Set.mem touches x) -> count_cycles_from (path_continues_to p v)
    | x -> 0
and count_cycles_from (p: path): int = 
  let (start, stop, touches, g) = p in 
  let next = match Map.find g stop with 
  | Some l -> l
  | None -> [] in 
  sum_list (List.map next (fun v -> count_cycles_at p v))

let count_cycles (g: graph): int = 
  sum_list (List.map (Map.keys g) (fun (v) -> count_cycles_from (v, v, String.Set.empty, g)))  
  
let () = 
  let nargs = Array.length Sys.argv in 
  let n = if nargs > 1 then Sys.argv.(1) else "20" in 
  let fn = Printf.sprintf "../data/graph%s.adj" n in 
  let lines = read_file fn in 
  let g = read_graph lines in 
  print_newline (print_int (count_cycles g))
  ;;

