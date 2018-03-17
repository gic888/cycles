package main

import (
	"cycles"
    "fmt"
	"os"
)

func main() {

	size := os.Args[1]
	ifn := "../data/graph" + size +".adj"
	g, e := cycles.ReadGraph(ifn)
	if e!=nil {
		fmt.Println(e)
		panic(e)
	}
	var n int
	if len(os.Args) > 2 && os.Args[2] == "sync" {
		n = len(cycles.CyclesSync(g))
	} else {
		n = cycles.CountCycles(g)
	}
	fmt.Println(n)
}


