/*
 * This Java source file was generated by the Gradle 'init' task.
 */
import kotlinx.coroutines.experimental.runBlocking
import org.junit.Test
import org.junit.Assert.*

class AppTest {
    @Test
    fun testSmallGraph() = runBlocking<Unit> {
        val graph = readGraph("../data/graph20.adj")
        assert(App.countCyclesAsync(graph) == 89)
        assert(App.countCyclesSync(graph) == 89)
        println("count correct")
    }
}
