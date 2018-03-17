import networkx as nx
from networkx.generators.random_graphs import binomial_graph

if __name__ == '__main__':
    n = 37
    p = .1
    g = binomial_graph(n, p, None, True)
    nx.write_adjlist(g, '../data/graph{}.adj'.format(n))

