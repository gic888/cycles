const g20 = `
0 4 10 19
1 0 6 9
2
3 4 11 19
4 1
5 1 4 12
6 14
7 3 8 13 19
8 1
9
10 14 18
11 12
12 5 16
13
14 16
15 10 11
16 0 17
17 3
18 3 8 12
19 1 2 5 8 9 17 18
`;

const g35 = `
0 33
1 2 18 25
2 3 4 17 27
3 12 20 25
4 28 30
5 1 11 31
6 9 17 26 30 34
7 5 19
8 2 4 9 17
9 5 14 15 24 27 33 34
10 12 14 18 30 34
11 1 2 13 16 32
12 3 26 27 28 32
13 8 25 28
14 22
15 8 14 24 31
16 17 18 29
17 9 16 22 33 34
18 3 9 14 16 22 26
19 3 7 16
20 5 14 16 33
21 11
22
23 0 5 31
24 26 34
25 7 20
26 6 10 13 15 28
27 15 16 21
28 11 27 33
29 2 3
30 6 18 23
31 10 11 12 33
32 3 4 5 14 30
33 32
34 13 17 22
`;


function count_cycles_at(vertex, path, graph) {
    if (vertex === path[0]) {
        return 1
    } else if (vertex > path[0] && !path.includes(vertex)) {
        return count_cycles_from(path.concat([vertex]), graph)
    } else {
        return 0;
    }
}

function count_cycles_from(path, graph) {
    let i = 0;
    graph[path[path.length -1]].forEach(function(target) {
        i += count_cycles_at(target, path, graph);
    });
    return i;
}

function count_cycles(graph) {
    let i = 0;
    Object.keys(graph).forEach(function(v) {
            i += count_cycles_from([v], graph);
        }
    );
    return i;
}

function load_graph(data) {
    let lines = data.split('\n');
    let graph = {};
    for (i = 0; i < lines.length; i++) {
        if (lines[i].length === 0 || lines[i].startsWith('#')) {
            continue;
        }
        let words = lines[i].split(' ');
        graph[words[0]] = words.slice(1)
    }
    return graph;
}

function report(data) {
    let start = new Date().getTime();
    let n = count_cycles(load_graph(data));
    let stop = new Date().getTime();
    document.getElementById("output").innerHTML = `JavaScript: Found ${n} cycles in ${stop - start} ms `;
}


document.getElementById("g20b").onclick = function() { report(g20) };

document.getElementById("g35b").onclick = function() { report(g35) };




