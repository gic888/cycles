package cycles

import (
	"time"
	"fmt"
)


func CountCycles(graph Graph) int {
	verts := graph.Vertices()
	ch := make([]chan []string, len(verts))
	for i, v := range verts {
		ch[i] = make(chan []string)
		go genCycles(v, graph, ch[i])
	}
	n := 0
	for _, c := range ch {
		for range c {
			n++
		}
	}
	return n
}

func count(paths chan []string, cc chan int) {
	n := 0
	for range paths {
		n++
		fmt.Printf(".")
	}
	cc <- n
}

func CyclesSync(graph Graph) [][]string {
	paths := make([][]string, 0)
	for _, v := range graph.Vertices() {
		paths = append(paths, genCyclesFromPathSync([]string{v}, graph)...)
	}
	return paths
}

func genCyclesFromPathSync(path []string, graph Graph) [][]string {
	cycles := make([][]string, 0)
	if len(path) == 0 {
		return cycles
	}
	vid := path[0]
	tip := path[len(path) -1]
	for _, tid := range graph.Edges(tip) {
		if tid == vid {
			cycles = append(cycles, path)
		} else if tid > vid && !contains(path[1:], tid) {
			cycles = append(cycles, genCyclesFromPathSync(append(path, tid), graph)...)
		}
	}
	return cycles
}

func genCycles(vertex string, graph Graph, ch chan []string) {
	for _, v := range genCyclesFromPathSync([]string{vertex}, graph) {
		ch <- v
	}
	close(ch)
}

func genCyclesFromPathAsync(path []string, graph Graph, ch chan []string, rc chan int) {
	if len(path) == 0 {
		rc <- -1
		return
	}
	vid := path[0]
	tip := path[len(path) -1]
	for _, tid := range graph.Edges(tip) {
		if tid == vid {
			ch <- path
		} else if tid > vid && !contains(path[1:], tid) {
			rc <- 1
			np := make([]string, 0)
			np = append(np, path...)
			np = append(np, tid)
			go genCyclesFromPathAsync(np, graph, ch, rc)
		}
	}
	rc <- -1
}

func contains(s []string, e string) bool {
    for _, a := range s {
        if a == e {
            return true
        }
    }
    return false
}

func chanMonitor(ch chan []string, rc chan int) {
	refs := 0
	for {
		v := <-rc
		refs += v
		fmt.Printf("*")
		if refs < 1 {
			time.Sleep(10 * time.Millisecond)
			close(ch)
			break
		}
	}

}
