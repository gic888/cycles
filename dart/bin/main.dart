import 'package:dart/dart.dart' as dart;

main(List<String> arguments) async {
  var fn = '../data/graph${arguments.length > 0 ? arguments[0] : '20'}.adj';
  var g = dart.read(fn);
  var n = await dart.count_cycles(g);
  print('$n');
}
