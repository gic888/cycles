import 'dart:html';
import 'dart:async';

void main() {
  querySelector('#output').text = 'Your Dart app is running.';
}

Future<int> count_cycles(Map<String, List<String>> g) async {
  return Future
      .wait(g.keys.map( (v) => _cycles_starting_at(v, g)))
      .then((List<int> counts) => _lsum(counts));
}

Future<int> _cycles_starting_at(String v, Map<String, List<String>> g) async {
  return _lsum(g[v].map((t) => _cycles_at(t, [v], g)));
}

int _lsum(Iterable<int> l) {
  if (l.length == 0) {
    return 0;
  } else {
    return l.reduce((i,j) => i + j);
  }
}

int _cycles_at(String v, List<String> path, Map<String, List<String>> g) {
  if (v == path[0]) {
    return 1;
  } else if (v.compareTo(path[0]) > 0 && !path.contains(v) && g.containsKey(v) && !g[v].isEmpty) {
    var np = [];
    np.addAll(path);
    np.add(v);
    return _lsum(g[v].map((t) => _cycles_at(t, np, g)));
  } else {
    return 0;
  }
}

Map<String, List<String>> read(String data) {
  var raw_lines = data.split("\n");
  var lines = raw_lines
      .map((s) => s.trim())
      .where((s) => s.length > 0 && !s.startsWith("#"))
      .map((s) => s.split(" "));
  return new Map.fromIterable(lines,
      key: (l) => l[0], value: (List<String> l) => l.sublist(1, l.length));
}


const g20 = '''
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
''';

const g35 = '''
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
''';