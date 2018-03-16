import networkx as nx
from networkx.generators.random_graphs import binomial_graph

if __name__ == '__main__':
    g = binomial_graph(20, .1, None, True)
    nx.write_yaml(g, '../data/graph.yaml')

