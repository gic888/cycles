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
	n := len(cycles.CyclesSync(g))
	if n != 89 {
		t.Error(fmt.Sprintf("wrong cycle count for sync list %i (expected 89)", n))
	}
	n = cycles.CountCycles(g)
	if n != 89 {
		t.Error(fmt.Sprintf("wrong cycle count for async count %i (expected 89)", n))
	}
}
