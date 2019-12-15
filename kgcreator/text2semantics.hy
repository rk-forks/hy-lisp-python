#!/usr/bin/env hy

;; library text2semantics: convert text to structured NLP data

(import spacy)

(setv nlp-model (spacy.load "en"))

(defn find-entities-in-text [some-text]
  (setv doc (nlp-model some-text))
  (lfor entity doc.ents [entity.text entity.label_]))
 
(print (find-entities-in-text "President George Bush went to Mexico and he had a very good meal"))
(print (find-entities-in-text "Lucy threw a ball to Bill and he caught it"))
