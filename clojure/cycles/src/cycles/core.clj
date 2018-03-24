(ns cycles.core
  (:gen-class))

(use '[clojure.string :only (split starts-with? blank?)])

(defrecord Graph [data])

(defn usable_line [l] (not (or (blank? l) (starts-with? l "#"))))

(defn line_head_tail_pair [line]
  (let [l (split line #"\s")]
    [(first l) (vec (next l))]
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


(defn string_lt
  [s1 s2]
  (< (compare s1 s2) 0)
  )

(defn should_continue
  [path e]
  (not (or (string_lt e (first path)) (some #{e} path)))
  )

(defn count_cycles_in_path
  [path, edges]
  (reduce +
          (map
            (fn [e]
              (if (= e (first path))
                1 (if (should_continue path e) (count_cycles_in_path (conj path e) edges) 0)
                )
              )
            (edges (last path)))
          )
  )





(defn count_cycles_sync
  [^Graph g]
  (let [edges (fn [x] (get (:data g) x))]
    (let [ns (map (fn [v] (count_cycles_in_path [v], edges)) (keys (:data g)))]
      (reduce + ns)
      )
    )
  )

(defn count_cycles
  [^Graph g]
  2
  )


(defn -main
  "I don't do a whole lot ... yet."
  [& args]
  (println
    (let [nargs (count args)]
      (let [
            g (read_graph (str "../../data/graph" (if (> nargs 0) (first args) "20") ".adj"))
            async (if (> nargs 1) (== (second args) "sync") false)
            ]
        (if async (count_cycles g) (count_cycles_sync g))
        )
      )
    )
  )

