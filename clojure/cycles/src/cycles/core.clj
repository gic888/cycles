(ns cycles.core
  (:gen-class))

(require '[clojure.core.reducers :as r])
(use '[clojure.string :only (split starts-with? blank?)])

(defrecord Graph [data])

(defrecord Path [start stop middle])

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
  (not (or (string_lt e (:start path)) ((:middle path) e)))
  )


(defn path_with
  [path e]
  (Path. (:start path) e (conj (:middle path) e))

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





(defn count_cycles_sync
  [^Graph g]
  (let [edges (fn [x] (get (:data g) x))]
    (let [ns (map (fn [v] (count_cycles_in_path (Path. v v #{}), edges)) (keys (:data g)))]
      (reduce + ns)
      )
    )
  )

(defn count_cycles
  [^Graph g]

  (let [edges (fn [x] (get (:data g) x))]
    (let [ns (map (fn [v] (count_cycles_in_path (Path. v v #{}), edges)) (keys (:data g)))]
      (r/fold + ns)
      ))
  )


(defn -main
  "I don't do a whole lot ... yet."
  [& args]
  (println
    (let [nargs (count args)]
      (let [
            g (read_graph (str "../../data/graph" (if (> nargs 0) (first args) "20") ".adj"))
            async (if (> nargs 1) (= (second args) "async") false)
            ]
        (if async (count_cycles g) (count_cycles_sync g))
        )
      )
    )
  )

