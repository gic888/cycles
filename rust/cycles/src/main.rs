#[macro_use]
extern crate log;
extern crate env_logger;

use std::collections::HashMap;
use std::env;
use std::fs::File;
use std::io::{BufReader, BufRead};
use std::thread;
use std::sync::mpsc;
use std::time::{SystemTime};

#[derive(Clone)]
struct Graph {
    data: HashMap<i32, Vec<i32>>,
    empty: Vec<i32>

}

impl Graph {

    fn read(file: String) -> Graph {
        env_logger::init();
        let empty = vec![];
        let mut data = HashMap::new();
        let f = match File::open(&file) {
            Ok(v) => v,
            Err(_e) => {
                error!("failed to load file {}", file);
                return Graph { data, empty };
            }
        };
        let buffered = BufReader::new(f);

        for line in buffered.lines() {
            match line {
                Ok(s) => read_line(&mut data, s),
                _ => info!("no line"),
            }
        }
        return Graph { data, empty }
    }

    fn size(&self) -> usize {
        self.data.len()
    }

    fn edges(&self, vertex: i32) -> &Vec<i32> {
        match self.data.get(&vertex) {
            Some(v) => &v,
            None => &(self.empty)
        }
    }
}

fn read_line(map: &mut HashMap<i32, Vec<i32>>, line: String) {
    if line.len() > 0 && !line.starts_with("#") {
        let mut iter = line.split(" ");
        let first: i32 = match iter.next() {
            Some(s) => read_int(s),
            _ => 0
        };
        let v: Vec<i32> = iter.map(|ls| { read_int(ls) }).collect();
        map.insert(first, v);
        ()
    }
}

fn read_int(s: &str) -> i32 {
    match s.parse::<i32>() {
        Ok(i) => i,
        _ => 0
    }

}

fn main() {
    let args: Vec<String> = env::args().collect();
    let ref n = if args.len() > 1 {
        &args[1]
    } else {
        "20"
    };
    let ref mode = if args.len() > 2 {
        &args[2]
    } else {
        "cheese"
    };
    let start = SystemTime::now();
    let path = format!("../../data/graph{}.adj", n);
    let graph = Graph::read(path);
    println!("graph size {}. Mode {}", graph.size(), mode);
    let n: i64 = match mode {
        &"sync" => find_cycles_sync(graph, false),
        &"sync_cheese" => find_cycles_sync(graph, true),
        &"cheese" => find_cycles(graph, true),
        _ => find_cycles(graph, false)
    };
    let t = SystemTime::now().duration_since(start).expect("time passes");
    let ms = t.as_secs() * 1000 + t.subsec_nanos() as u64 / 1_000_000;
    println!("found {} cycles in {} ms", n, ms);
}

fn find_cycles_sync(graph: Graph, extra_cheese: bool) -> i64 {
    let mut n: i64 = 0;
    for k in graph.data.keys() {
        n = n + count_starting_at(*k, &graph, extra_cheese);;
    };
    return n;
}

fn find_cycles(graph: Graph, extra_cheese: bool) -> i64 {
    let keys = graph.data.keys();
    let (tx, rx) = mpsc::channel();
    for k in keys {
        let txc = mpsc::Sender::clone(&tx);
        let gc = Graph::clone(&graph);
        let kc=*k;
        thread::spawn(move || {
            let nc = count_starting_at(kc, &gc, extra_cheese);
            txc.send(nc).unwrap();
        });
    }
    let mut n: i64 = 0;
    let mut reads = 0;
    while reads < graph.size() {
        n = n + rx.recv().unwrap();
        reads += 1
    }
    return n;
}

fn count_starting_at(vertex: i32, graph: &Graph,  extra_cheese: bool) -> i64 {
    if extra_cheese {
        return count_cycles_c_style(vertex, vertex, 0, graph);
    } else {
        return count_cycles_from(vec![&vertex], graph);
    }

}

fn count_cycles_from(path: Vec<&i32>, graph: &Graph) -> i64 {
    let mut n: i64 = 0;
    let end: i32 = *path[path.len() - 1];
    let start: i32 = *path[0];
    for tid in graph.edges(end) {
        if tid == &start {
            n = n + 1;
        } else if tid > &start && !path.contains(&&tid) {
            let mut np = path.clone();
            np.push(&tid);
            n = n + count_cycles_from(np, graph);
        };
    };
    n
}

fn count_cycles_c_style(start: i32, end: i32, path_mask: u64, graph: &Graph) -> i64 {
    let mut count: i64 = 0;
    for tid in graph.edges(end) {
        let target = *tid;
        if target == start {
            count += 1;
        } else if target > start {
            let target_mask: u64 = 1 << target;
            let in_path = path_mask & target_mask;
            if in_path == 0 {
                count += count_cycles_c_style(start, target, path_mask | target_mask, graph);
            }
        }
    }
    return count;
}



