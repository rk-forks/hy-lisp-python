(import [pprint [pprint]])
(require [hy.contrib.walk [let]])

(import [sparql [dbpedia-sparql]])
(import [colorize [colorize-sparql]])

;;(import [textui [select-entities get-query]])

(defn dbpedia-get-relationships [s-uri o-uri]
  (let [query
        (.format
          "SELECT DISTINCT ?p {{  {} ?p {} . FILTER (!regex(str(?p), 'wikiPage', 'i')) }} LIMIT 5"
          s-uri o-uri)
        results (dbpedia-sparql query)]
    (print "Generated SPARQL to get relationships between two entities:")
    (print (colorize-sparql query))
    (lfor r (flatten results) :if (not (= r "p")) r)))

(defn entity-results->relationship-links [uris]
  (setv uris (lfor uri uris (+ "<" uri ">")))
  (setv relationship-statements [])
  (for [e1 uris]
    (for [e2 uris]
      (if (not (= e1 e2))
          (let [l1 (dbpedia-get-relationships e1 e2)
                l2 (dbpedia-get-relationships e2 e1)]
              (for [x l1]
                (if (not (in [e1 e2 x] relationship-statements))
                    (.extend relationship-statements [[e1 e2 x]])))
              (for [x l2]
                 (if (not (in [e1 e2 x] relationship-statements))
                     (.extend relationship-statements [[e1 e2 x]])))))))
  relationship-statements)

;;(pprint (entity-results->relationship-links ["http://dbpedia.org/resource/Bill_Gates" "http://dbpedia.org/resource/Microsoft"]))
