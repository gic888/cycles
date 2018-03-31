module Cycles
open System
open Microsoft.FSharp.Collections
open System.IO
open System.Globalization

type Graph = Map<string, string list>

let rec count_cycles_at (v: string) (start: string) (stop: string) (path: Set<string>) (graph: Graph): int = 
    match v with 
            | x when x = start -> 1
            | x when x > start && not (Set.contains x path) -> count_cycles_from start v (Set.add v path) graph
            | _ -> 0
and count_cycles_from (start: string) (stop: string) (path: Set<string>) (graph: Graph): int = 
    let next = Map.find stop graph 
    let counts = List.map (fun x -> count_cycles_at x start stop path graph) next
    match counts with 
        | [] -> 0
        | _ -> List.reduce ( + ) counts

let count_cycles (g: Graph): int  = 
    let verts = List.map fst (Map.toList g)
    let countAtVert = fun (x: String) -> count_cycles_from x x Set.empty g
    List.reduce ( + ) (List.map countAtVert verts)

let test_graph = Map [("a", ["b"; "c"]); ("b", ["c"]); ("c", ["a"])]

let readLines (fn : string) = seq {
    use sr = new StreamReader (fn)
    while not sr.EndOfStream do
        yield sr.ReadLine ()
}

let to_alist (line: string): string * string list = 
    let words = Array.toList (line.Split [|' '|]) 
    (List.head words, List.tail words)

let read_graph (fn: string): Graph = 
    Map (Seq.map to_alist (Seq.filter (fun s -> String.length s > 0 && s.Chars(0) <> '#') (readLines fn) ))

[<EntryPoint>]
let main argv =
    let n = if argv.Length > 0 then argv.[0] else "20"
    let fn = String.Format("../data/graph{0}.adj", n)
    let g = read_graph fn
    let n = count_cycles g 
    printfn "%i" n
    0 // return an integer exit code
