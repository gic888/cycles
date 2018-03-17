package main

import (
	"testing"
	"cycles"
	"fmt"
)

func TestCountCycles(t *testing.T) {
	ifn := "../../../data/graph20.adj"
	g, e := cycles.ReadGraph(ifn)
	if e!=nil {
		fmt.Println(e)
		t.Error(e)
	}
	n := cycles.CountCycles(g)
	if n != 89 {
		println(n)
		t.Error("wrong cycle count")
	}
}
