#!/usr/bin/env hy

(import json)
(import os)
(import sys)
(import [pprint [pprint]])
(import requests)
(import pickle)
(require [hy.contrib.walk [let]])

(import [cache [fetch-result-dbpedia save-query-results-dbpedia]])

;;(setv query (get sys.argv 1)) ;; "select ?s ?p ?o { ?s ?p ?o } limit 2"

(setv wikidata-endpoint "https://query.wikidata.org/bigdata/namespace/wdq/sparql")
(setv dbpedia-endpoint "https://dbpedia.org/sparql")

(defn do-query-helper [endpoint query]
  ;; check cache:
  (setv cached-results (fetch-result-dbpedia query))
  (print "cached results:") (print cached-results)
  (if (> (len cached-results) 0)
      (eval cached-results)
      (let ()
        ;; Construct a request
        (setv params { "query" query "format" "json"})
        
        ;; Call the API
        (setv response (requests.get endpoint :params params))
        (print "response:") (print response) (print response.status_code)
        
        (setv json-data (response.json))
        
        (setv vars (get (get json-data "head") "vars"))
        
        (setv results (get json-data "results"))
        
        (if (in "bindings" results)
            (let [bindings (get results "bindings")
                  qr
                  (lfor binding bindings
                        (lfor var vars
                              [var (get (get binding var) "value")]))]
              (save-query-results-dbpedia query qr)
              qr)
            []))))

(defn wikidata-sparql [query]
  (do-query-helper wikidata-endpoint query))

(defn dbpedia-sparql [query]
  (do-query-helper dbpedia-endpoint query))

;;(pprint (wikidata-sparql query))
(pprint (dbpedia-sparql "select ?s ?p ?o { ?s ?p ?o } limit 3"))
