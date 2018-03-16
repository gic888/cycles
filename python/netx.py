import networkx as nx

if __name__ == '__main__':
    from sys import argv
    if len(argv) > 1:
        n = argv[1]
    else:
        n = '20'
    g = nx.DiGraph()
    nx.read_adjlist('../data/graph' + n + '.adj', create_using=g)
    cycles = list(nx.simple_cycles(g))
    print(len(cycles))
    # for x in sorted(cycles):
    #    print(" ".join(x))
