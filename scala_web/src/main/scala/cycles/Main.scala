package cycles

import java.util.Date

import scala.collection.immutable.HashMap

object Main extends CycleDetector {
  def main(args: Array[String]): Unit = {
    println(countCycles(rawData.g35))
  }
}

trait CycleDetector {
  def countCycles(data: String): String = {
    val start = new Date().getTime
    val n = countCyclesSync(MapGraph.read(data))
    val t = new Date().getTime - start
    return s"Counted $n cycles in $t"
  }

  def countCyclesSync(graph: Graph): Int =
    graph.vertices().map(v => countCycles(Path.root(v, graph))).sum

  def countCycles(path: Path): Int = path.continuesTo().map(tid =>
    if (tid == path.start) 1
    else if (tid > path.start && !path.seq.contains(tid)) countCycles(path.and(tid))
    else 0).sum

  def findCycles(path: Path): Seq[Path] = {
    path.continuesTo().flatMap(tid =>
      if (tid == path.start) Seq(path)
      else if (tid > path.start && !path.seq.contains(tid)) findCycles(path.and(tid))
      else Seq()
    )
  }
}

case class Path(start: String, seq: Map[String, Int], end: String, graph: Graph) {
  def continuesTo(): Seq[String] = graph.edges(end)

  def and(step: String): Path = Path(start, seq + (step -> seq.size), step, graph)
}

object Path {
  def root(start: String, graph: Graph): Path = Path(start, HashMap(), start, graph)
}

trait Graph {
  def vertices(): Seq[String]

  def edges(vertex: String): Seq[String]
}

case class MapGraph(m: Map[String, Seq[String]]) extends Graph {
  override def vertices(): Seq[String] = m.keys.toSeq

  override def edges(vertex: String): Seq[String] = m.getOrElse(vertex, Seq())
}

object MapGraph {
  def read(data: String): Graph = MapGraph(
    data.split("\n")
      .map(_.trim())
      .filter(!_.startsWith("#"))
      .map(_.split(" "))
      .map(s => s(0) -> s.toSeq.slice(1, s.length))
      .toMap
  )
}

object rawData {
  val g20 =
    """
0 4 10 19
1 0 6 9
2
3 4 11 19
4 1
5 1 4 12
6 14
7 3 8 13 19
8 1
9
10 14 18
11 12
12 5 16
13
14 16
15 10 11
16 0 17
17 3
18 3 8 12
19 1 2 5 8 9 17 18
"""

  val g35 =
    """
0 33
1 2 18 25
2 3 4 17 27
3 12 20 25
4 28 30
5 1 11 31
6 9 17 26 30 34
7 5 19
8 2 4 9 17
9 5 14 15 24 27 33 34
10 12 14 18 30 34
11 1 2 13 16 32
12 3 26 27 28 32
13 8 25 28
14 22
15 8 14 24 31
16 17 18 29
17 9 16 22 33 34
18 3 9 14 16 22 26
19 3 7 16
20 5 14 16 33
21 11
22
23 0 5 31
24 26 34
25 7 20
26 6 10 13 15 28
27 15 16 21
28 11 27 33
29 2 3
30 6 18 23
31 10 11 12 33
32 3 4 5 14 30
33 32
34 13 17 22
"""
}
