(ns cycles.core
  (:gen-class))

(defrecord Graph [data])

(defn read_graph 
  [^java.lang.String path]
  (with-open [rdr (clojure.java.io/reader path)]
    (Graph. {:a (count (line-seq rdr)) })
  )
)

(defn count_cycles_sync
  [^Graph g]
  (get (:data g) :a)
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
        async (if (> nargs 1) ( == (second args) "sync") false)
      ]
        (if async (count_cycles g) (count_cycles_sync g))
      )
    )
  )
)
