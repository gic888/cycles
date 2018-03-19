#[macro_use]
extern crate log;
extern crate env_logger;

use std::collections::HashMap;
use std::env;
use std::fs::File;
use std::io::{BufReader, BufRead};

struct Graph {
    data: HashMap<i32, Vec<i32>>

}

impl Graph {
    fn read(file: String) -> Graph {
        env_logger::init();
        let mut data = HashMap::new();
        let f = match File::open(file) {
            Ok(v) => v,
            Err(_e) => {
                error!("failed to load file");
                return Graph { data };
            }
        };
        let buffered = BufReader::new(f);

        for line in buffered.lines() {
            match line {
                Ok(s) => read_line(&mut data, s),
                _ => info!("no line"),
            }
        }

        return Graph { data }
    }

    fn size(&self) -> usize {
        self.data.len()
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
    let ref n = if args.len() > 0 {
        &args[0]
    } else {
        "20"
    };
    let ref mode = if args.len() > 1 {
        &args[1]
    } else {
        "async"
    };
    let path = format!("../../../data/graph{}.adj", n);
    let graph = Graph::read(path);
    match mode {
        &"sync" => find_cycles_sync(graph),
        _ => find_cycles(graph)
    }
}

fn find_cycles_sync(graph: Graph) {
    println!("graph size {}", graph.size())

}

fn find_cycles(graph: Graph) {
    println!("graph size {}", graph.size())
}




