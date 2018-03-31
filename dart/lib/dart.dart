import 'dart:io';
import 'dart:async';

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

Map<String, List<String>> read(String fn) {
  final file = new File(fn);
  var lines = file.readAsLinesSync()
    .map((s) => s.trim())
    .where((s) => s.length > 0 && !s.startsWith("#"))
    .map((s) => s.split(" "));
  return new Map.fromIterable(lines,
    key: (l) => l[0], value: (List<String> l) => l.sublist(1, l.length));
}





