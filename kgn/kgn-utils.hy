#!/usr/bin/env hy

(import [sparql [dbpedia-sparql]])

(import [pprint [pprint]])
(require [hy.contrib.walk [let]])

(defn dbpedia-get-entities-by-name [name dbpedia-type schema-org-type]
  (let [sparql
        (.format "select distinct ?s ?comment {{ ?s ?p \"{}\"@en . ?s <http://www.w3.org/2000/01/rdf-schema#comment>  ?comment  . FILTER  (lang(?comment) = 'en') . ?s <http://www.w3.org/1999/02/22-rdf-syntax-ns#type> {} . }} limit 15" name dbpedia-type)
        results
        (dbpedia-sparql sparql)]
    (pprint sparql)
    (pprint results)))

(pprint (dbpedia-get-entities-by-name "Bill Gates" "<http://dbpedia.org/ontology/Person>" "<http://schema.org/Person>"))
