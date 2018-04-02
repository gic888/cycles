using System;
using System.Collections.Generic;
using System.Linq;

namespace csharp
{
    class Program
    {

        static Int32 countCyclesAt(String vertex, String[] path, Dictionary<String, String[]> graph) {
            if (vertex == path[0]) {
                return 1;
            } else if (vertex.CompareTo(path[0]) > 0 && !path.Contains(vertex)) {
                var p = new String[path.Length + 1];
                path.CopyTo(p, 0);
                p[path.Length] = vertex;
                return countCyclesFrom(p, graph);
            } else {
                return 0;
            }

        }
        static Int32 countCyclesFrom(String[] path, Dictionary<String, String[]> graph) {
            var i = 0;
            foreach (String vertex in graph[path[path.Length -1]]) {
                i += countCyclesAt(vertex, path, graph);
            }
            return i;
        }

        static Int32 countCycles(Dictionary<String, String[]> graph) {
            var i = 0;
            foreach (String vertex in graph.Keys) {
                i += countCyclesFrom(new String[] { vertex }, graph);
            }
            return i;
        }

        static Dictionary<String, String[]> readGraph(String fn) {
            var g = new Dictionary<String, String[]>();
            foreach (String l in System.IO.File.ReadAllLines(fn)) {
                if (l.Length == 0 || l.StartsWith("#")) {
                    continue;
                }
                var words = l.Split(" ");
                g[words[0]] = words.Skip(1).ToArray();
            }
            return g;
        }

        static void Main(String[] args)
        {
            var start = DateTime.Now;
            var gsize = "20";
            if (args.Length > 0) {
                gsize = args[0];
            }
            var g = readGraph($"../data/graph{gsize}.adj");
            var c = countCycles(g);
            var t = DateTime.Now.Subtract(start).TotalMilliseconds;
            Console.WriteLine($"Counted {c} cycles in {t} ms");
        }
    }
}
