package cycles

import scala.io.Source
import scala.concurrent.ExecutionContext.Implicits.global
import scala.concurrent.Future

object Main extends CycleDetector {
  def main(args: Array[String]): Unit = {
    println(countCycles(args))
  }
}

trait CycleDetector {
  def countCycles(args: Array[String]): Int = {
    val n = if (args.length > 0) args(0) else "20"
    val fn = s"../../data/graph$n.adj"
    val g = MapGraph.read(fn)
    val mode = if (args.length > 1) args(1) else "future"
    mode match {
      case "sync" => countCyclesSync(g)
      case _ => countCycle(g)
    }
  }

  def countCyclesSync(graph: Graph): Int =
    graph.vertices().map(v => findCycles(Seq(v), graph).count(z => true)).sum


  def countCycle(graph: Graph): Int = {
    val futures = graph.vertices().map(v => Future {
      findCycles(Seq(v), graph)
    })
    futures.map( f => f.value )
      .filter( t => t.nonEmpty)
      .map( _.get )
      .filter( _.isSuccess )
      .map( _.get.count( z => true) )
      .sum
  }


  def findCycles(path: Seq[String], graph: Graph): Seq[Seq[String]] = {
    if (path.isEmpty) {
      return Seq()
    }
    graph.edges(path.last).flatMap( tid =>
      if (tid == path.head) Seq(path)
      else if (tid > path.head && !path.contains(tid)) findCycles(path :+ tid, graph)
      else Seq()
    )
  }
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
