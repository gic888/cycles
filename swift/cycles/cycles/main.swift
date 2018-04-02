//
//  main.swift
//  cycles
//
//  Created by Graham Cummins on 4/2/18.
//  Copyright © 2018 symbolscope.com. All rights reserved.
//

import Foundation

func countCyclesAt(vertex: String, path: Array<String>, graph: Dictionary<String, Array<String>>) -> Int {
    if vertex == path[0] {
        return 1
    } else if vertex > path[0] && !path.contains(vertex) {
        return countCyclesFrom(path: path + [vertex], graph: graph)
    } else {
        return 0
    }
    
}

func countCyclesFrom(path: Array<String>, graph: Dictionary<String, Array<String>>) -> Int {
    var i = 0
    if let next = graph[path[path.count - 1]] {
        for vertex in next {
            i = i + countCyclesAt(vertex: vertex, path: path, graph: graph)
        }
    }
    return i
}

func countCycles(graph: Dictionary<String, Array<String>>) -> Int {
    var i = 0
    for vertex in graph.keys {
        i = i + countCyclesFrom(path: [vertex], graph: graph)
    }
    return i
}

func readGraph(fn: String) -> Dictionary<String, Array<String>> {
    var g = [String: Array<String>]()
    let url = FileManager.default.homeDirectoryForCurrentUser
        .appendingPathComponent("code")
        .appendingPathComponent("cycles")
        .appendingPathComponent("data")
        .appendingPathComponent(fn)
    do {
        let s = try String(contentsOf: url, encoding: .utf8)
        for line in s.split(separator: "\n", maxSplits: 1000, omittingEmptySubsequences: true) {
            if line.isEmpty || line.starts(with: "#") {
                continue
            }
            let words = line.split(separator: " ", maxSplits: 1000, omittingEmptySubsequences: true)
            g[String(words[0])] = words.dropFirst().map( {(s: Substring.SubSequence) -> String in String(s)})
        }
    } catch {
        print("Error reading \(error)")
    }
    
    return g
}

let f = CommandLine.argc > 1 ? CommandLine.arguments[1] : "35"
let start = Date()
let g = readGraph(fn:  "graph\(f).adj")
let n = countCycles(graph: g)
let stop = Date()
print("Counted \(n) cycles in \(stop.timeIntervalSince(start)) sec")

