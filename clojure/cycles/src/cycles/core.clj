(ns cycles.core
  (:gen-class))

(use '[clojure.string :only (split starts-with? blank?)])

(defrecord Graph [data])

(defrecord Path [start stop middle])

(defn usable_line [l] (not (or (blank? l) (starts-with? l "#"))))

(defn line_head_tail_pair
  [line]
  (let [l (split line #"\s")]
    [(read-string  (first l)) (vec (map read-string (next l)))]
    )
  )

(defn line_map [lines]
  (apply hash-map
         (mapcat line_head_tail_pair
                 (filter usable_line lines)
                 )
         )
  )

(defn read_graph
  [^java.lang.String path]
  (Graph. (with-open [rdr (clojure.java.io/reader path)] (line_map (line-seq rdr)))
          )
  )


(defn contained_in
  [mask e]
  (> (bit-and mask (bit-shift-left 1 e)) 0)
  )

(defn should_continue
  [path e]
  (not (or (< e (:start path)) (contained_in (:middle path) e)))
  )


(defn path_with
  [path e]
  (Path. (:start path) e (bit-or (:middle path) (bit-shift-left 1 e)))
)

(defn count_cycles_in_path
  [path, edges]
  (reduce +
          (map
            (fn [e]
              (if (= e (:start path))
                1 (if (should_continue path e) (count_cycles_in_path (path_with path e) edges) 0)
                )
              )
            (edges (:stop path)))
          )
  )

(defn count_cycles
  [^Graph g]

  (let [edges (fn [x] (get (:data g) x))]
    (let [ns (map (fn [v] (count_cycles_in_path (Path. v v 0), edges)) (keys (:data g)))]
      (reduce + ns)
      ))
  )

(defn -main
  "I don't do a whole lot ... yet."
  [& args]
  (println
    (let [nargs (count args)]
      (let [
            g (read_graph (str "../../data/graph" (if (> nargs 0) (first args) "20") ".adj"))
            ]
        (count_cycles g)
        )
      )
    )
  )

