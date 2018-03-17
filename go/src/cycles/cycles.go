package cycles

import (
	"fmt"
	"time"
)


func CountCycles(graph Graph) int {
	ch := make(chan []string, 10)
	rc := make(chan int)
	cc := make(chan int)
	go count(ch, cc, CyclesSync(graph))
	go chanMonitor(ch, rc)
	for _, v := range graph.Vertices() {
		rc <- 1
		go genCycles([]string{v}, graph, ch, rc)
	}
	return <-cc
}

func count(paths chan []string, cc chan int, expected [][]string) {
	n := 0
	matched := make(map[int]bool)
	for v := range paths {
		fmt.Printf("got  %v\n", v)
		i := indexOf(expected, v)
		if i == -1 {
			fmt.Printf("got unexpected path %v\n", v)
		} else if _, ok := matched[i]; ok {
			fmt.Printf("got duplicate path %v\n", v)
		} else {
			matched[i] = true
		}
		n++
	}
	if n < len(expected) {
		for i := range expected {
			if _, ok := matched[i]; !ok {
				fmt.Printf("missed expected path %v\n", expected[i])
			}
		}
	}
	cc <- n
}

func indexOf(paths [][]string, path []string) int {
	for i, p := range paths {
		if len(p) != len(path) {
			continue
		}
		for pi, pe := range p {
			if pe != path[pi] {
				break
			}
			if pi == len(p) - 1 {
				return i
			}
		}
	}
	return -1
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
			cycles = append(cycles, genCyclesFromPathSync(append(path[:], tid), graph)...)
		}
	}
	return cycles
}

func genCycles(path []string, graph Graph, ch chan []string, rc chan int) {
	fmt.Printf("genCycles called for %v\n", path)
	if len(path) == 0 {
		rc <- -1
		return
	}
	vid := path[0]
	tip := path[len(path) -1]
	for _, tid := range graph.Edges(tip) {
		if tid == vid {
			fmt.Printf("genCycles returning path %v\n", path)
			ch <- path
		} else if tid > vid && !contains(path[1:], tid) {
			rc <- 1
			np := make([]string, 0)
			np = append(np, path...)
			np = append(np, tid)
			fmt.Printf("genCycles recursive call to %v\n", np)
			go genCycles(np, graph, ch, rc)
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
		if refs < 1 {
			time.Sleep(1 * time.Second)
			close(ch)
			break
		}
	}

}
