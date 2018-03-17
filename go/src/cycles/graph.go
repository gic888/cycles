package cycles

import (
	"os"
	"bufio"
	"strings"
)

type Graph interface {
	Vertices() []string
	Edges(vertex string) []string
}

type MapGraph struct {
	vs map[string][]string
}

func (g MapGraph) Vertices() []string {
	var keys []string
	for k := range(g.vs) {
		keys = append(keys, k)
	}
	return  keys
}

func (g MapGraph) Edges(vertex string) []string {
	return g.vs[vertex]
}

func ReadGraph(path string) (g Graph, e error) {
	f, err := os.Open(path)
	if err != nil {
		return nil, e
	}
	defer f.Close()
	m := make(map[string][]string)

    scanner := bufio.NewScanner(f)
    for scanner.Scan() {
        line := strings.Trim(scanner.Text(), " ")
        if line[0] == '#' {
        	continue
		}
        list := strings.Split(line, " ")

        m[list[0]] = list[1:]
    }

    if err = scanner.Err(); err != nil {
        return nil, err
    }

	return MapGraph{m}, nil
}