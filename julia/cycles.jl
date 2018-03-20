
function count_paths(p, graph)
    n = 0
    edges = get(graph, p[length(p)], [])
    for e in edges
        if e == p[1]
            n = n + 1
        elseif e > p[1] && !(e in p)
            np = vcat(p, [e]) 
            n = n + count_paths(np, graph)
        end
    end
    return n
end

function count_cycles_sync(graph::Dict) 
    n = 0
    for k in keys(graph) 
        n = n + count_paths([k], graph)
    end
    return n
end

function count_cycles(graph::Dict) 
    return 1
end

function load_graph(file:: String) 
    f = open(file)
    lines = readlines(f)
    close(f)
    d = Dict()
    for l in lines
        if l[1] != '#'
            r = split(l)
            if length(r) > 0
                d[r[1]] = r[2:length(r)]
            end
        end
    end
    return d
end

function run(size, mode) 
    g = load_graph("../data/graph$size.adj")
    n =  mode == "sync" ? count_cycles_sync(g) : count_cycles(g)
    return n
end

size = length(ARGS) > 0 ? ARGS[1] : "20"
mode = length(ARGS) > 1 ? ARGS[2] : "async"
print(size, mode, "\n")
println(run(size, mode))