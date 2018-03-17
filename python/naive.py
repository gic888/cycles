
class DiGraph:
    def __init__(self):
        self.v = {}

    def add_vertex(self, id):
        self.v[id] = set()

    def add_edge(self, source, target):
        if not source in self.v:
            self.add_vertex(source)
        self.v[source].add(target)

    def vertices(self):
        for vid in self.v.keys():
            yield vid

    def edges(self, vid):
        if not vid in self.v:
            return
        for tid in self.v[vid]:
            yield tid


def find_cycles(path, graph):
    """

    :param path:
    :type path: List<str>
    :param graph:
    :type graph: DiGraph
    :return: Iterator<List<str>>

    """
    for tid in graph.edges(path[-1]):
        if tid == path[0]:
            yield path
        elif tid > path[0] and tid not in path[1:]:
            for cycle in find_cycles(path + [tid], graph):
                yield cycle


def find_all_cycles(graph):
    """
    :param graph:
    :type graph: DiGraph
    :return: Iterator<List<str>>
    """
    for vid in graph.vertices():
        for cycle in find_cycles([vid], graph):
            yield cycle


def read_adjacency(filename):
    lines = open(filename).readlines()
    graph = DiGraph()
    for line in lines:
        s = line.strip()
        if s.startswith("#"):
            continue
        ids = s.split()
        if len(ids) == 0:
            continue
        graph.add_vertex(ids[0])
        for id in ids[1:]:
            graph.add_edge(ids[0], id)
    return graph


if __name__ == '__main__':
    from sys import argv
    if len(argv) > 1:
        n = argv[1]
    else:
        n = '20'
    g = read_adjacency('../data/graph' + n + '.adj')
    i = 0
    for c in find_all_cycles(g):
        i += 1
    print(i)
