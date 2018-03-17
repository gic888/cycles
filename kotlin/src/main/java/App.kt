import kotlinx.coroutines.experimental.CommonPool
import kotlinx.coroutines.experimental.async
import kotlinx.coroutines.experimental.runBlocking
import java.io.File
import java.util.concurrent.Callable
import java.util.concurrent.Executors
import kotlin.coroutines.experimental.SequenceBuilder
import kotlin.coroutines.experimental.buildSequence


typealias ID = String
typealias Path = List<ID>

/*
 * This Java source file was generated by the Gradle 'init' task.
 */
object App {

    @JvmStatic
    fun main(args: Array<String>) {
        val n = if (args.isNotEmpty()) args[0] else "20"
        val graph = readGraph("../data/graph$n.adj")
        val mode = if (args.size > 1) args[1] else "deferred"
        println(mode)
        when (mode) {
            "sync" -> println(countCyclesSync(graph))
            else -> println(countCyclesAsync(graph))
        }
    }

    fun countCyclesAsync(graph: Graph): Int = runBlocking {
        val callables = graph.vertices().map { vid -> async(CommonPool) {
            buildSequence { findCycles(listOf(vid), graph)}.count()
        } }
        val ln: List<Int> = callables.map { it.await() }
        ln.sum()
    }

    fun countCyclesSync(graph: Graph): Int {
        val seq = buildSequence {
            for (v in graph.vertices()) {
                findCycles(listOf(v), graph)
            }
        }
        return seq.count()
    }
}


suspend fun SequenceBuilder<Path>.findCycles(path: Path, graph: Graph)  {
    if (path.isEmpty()) {
        return
    }
    for (tid in graph.edges(path.last())) {
        if (tid == path.first()) {
            yield(path)
        } else if (tid > path.first() && !path.contains(tid)) {
            findCycles(path + listOf(tid), graph)
        }
    }
}

fun readGraph(path: String): Graph =
        MapGraph(File(path).readLines(Charsets.UTF_8)
                .map { it.trim() }
                .filter { !it.startsWith("#") }
                .filter { !it.isEmpty() }
                .map { it.split(Regex("\\s"))}
                .map { it[0] to it.subList(1, it.size)
                }.toMap())



interface Graph {
    fun vertices(): Path
    fun edges(vertex: ID): Path
}

class MapGraph(private val vs: Map<ID, Path>): Graph {
    override fun vertices(): Path = vs.keys.toList()

    override fun edges(vertex: ID): Path = vs[vertex] ?: listOf()
}
