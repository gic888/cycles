#[macro_use]
extern crate log;
extern crate env_logger;

use std::collections::HashMap;
use std::env;
use std::fs::File;
use std::io::{BufReader, BufRead};

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
        "sync"
    };
    let path = format!("../../data/graph{}.adj", n);
    let graph = Graph::read(path);
    match mode {
        &"sync" => find_cycles_sync(graph),
        _ => find_cycles(graph)
    }
}

fn find_cycles_sync(graph: Graph) {
    println!("graph size {}", graph.size());
    let mut n = 0;
    for k in graph.data.keys() {
        n = n + count_cycles_from(vec![k], &graph);
    };
    println!("found {} cycles", n);
}

fn find_cycles(graph: Graph) {
    println!("graph size {}", graph.size());
}

fn count_cycles_from(path: Vec<&i32>, graph: &Graph) -> i32 {
    let mut n = 0;
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



