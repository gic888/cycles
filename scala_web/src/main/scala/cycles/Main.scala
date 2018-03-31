package cycles

import scala.collection.immutable.HashMap
import scala.io.Source
import scala.concurrent.ExecutionContext.Implicits.global
import scala.concurrent.{Await, Future}
import scala.concurrent.duration._

object Main extends CycleDetector {
  def main(args: Array[String]): Unit = {
    println(countCycles(Array("20")))
  }
}

trait CycleDetector {
  def countCycles(args: Array[String]): Int = {
    val n = if (args.length > 0) args(0) else "35"
    val fn = s"../../data/graph$n.adj"
    val g = MapGraph.read(fn)
    val mode = if (args.length > 1) args(1) else "futures"
    println(mode)
    mode match {
      case "sync" => countCyclesSync(g)
      case _ => countCycles(g)
    }
  }

  def countCyclesSync(graph: Graph): Int =
    graph.vertices().map(v => countCycles(Path.root(v, graph))).sum


  def countCycles(graph: Graph): Int = {
    val futures = graph.vertices().map(v => Future {
      countCycles(Path.root(v, graph))
    })
    futures.map( f => Await.result(f, 2 minutes) )
      .sum
  }

  def countCycles(path: Path): Int = path.continuesTo().map(tid =>
    if (tid == path.start) 1
    else if (tid > path.start && !path.seq.contains(tid)) countCycles(path.and(tid))
    else 0).sum

  def findCycles(path: Path): Seq[Path] = {
    path.continuesTo().flatMap( tid =>
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
  def read(path: String): Graph = MapGraph(
    Source.fromFile(path).getLines()
        .map( _.trim())
        .filter( !_.startsWith("#") )
        .map( _.split(" ") )
        .map( s => s(0) -> s.toSeq.slice(1, s.length) )
      .toMap
    )
}
