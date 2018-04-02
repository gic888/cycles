# Language Comparisons

The purpose of this project is to compare development experiences and performance across a number of languages by implementing a simple algorithm.

The objective of the algorithm is to count all unique simple cycles in a directed graph. Python's networkx.simple_cycles is a reference implementation. 

Several random graphs are included in the "data" directory, stored as text files in networkx's "adjacency" format. The format is very simple:

1. Blank lines are ignored, and lines starting with "#" are comments.
2. Each data line is a space separated list of vertex IDs. The first element describes a vertex in the graph, and the subsequent elements are the targets of all edges outgoing from this vertex.

Most implementations use graph20.adj (20 vertices) for testing, adn graph35.adj for benchmarking. These graphs contain 89 and 6973630 cycles respectively

Since the primary objective is to compare many languages, each implementation uses essentially the same algorithm, and no attempt has been made to pick an optimal algorithm. The algorithm used is a one-directional recursive search, started independently on each vertex (using orderability of vertices to avoid duplicate detection of the same cycle from different starting points)

Most implementations treat vertex IDs as strings, but a few cast them to integers. The algorithm used assumes only that they are some orderable data type. 

JavaScript platform implementations are measured in the Chrome browser, but so far they do not typically interact with a DOM - they simply log the result and time to compute to console. 
