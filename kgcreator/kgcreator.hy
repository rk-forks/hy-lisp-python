#!/usr/bin/env hy

(import [os [scandir]])
(import [os.path [splitext exists]])
(import spacy)

(setv nlp-model (spacy.load "en"))

(defn find-entities-in-text [some-text]
  (defn clean [s]
    (.strip (.replace s "\n" " ")))
  (setv doc (nlp-model some-text))
  (map list (lfor entity doc.ents [(clean entity.text) entity.label_])))

(defn Data2Rdf [meta-data entities fout]
  (for [[value abreviation] entities]
    (if (in abreviation e2umap)
      (.write fout (+ "<" meta-data ">\t" (get e2umap abreviation) "\t" "\"" value "\"" " .\n"))))
  )

(setv e2umap {
  "ORG" "<https://schema.org/Organization>"
  "LOC" "<https://schema.org/location>"
  "GPE" "<https://schema.org/location>"
  "NORP" "<https://schema.org/nationality>"
  "PRODUCT" "<https://schema.org/Product>"
  "PERSON" "<https://schema.org/Person>"
})


(defn process-directory [directory-name output-rdf]
  (with [frdf (open output-rdf "w")]
    (with [entries (scandir directory-name)]
      (for [entry entries]
        (setv [_ file-extension] (splitext entry.name))
        (if (= file-extension ".txt")
            (do
              (setv check-file-name (+ (cut entry.path 0 -4) ".meta"))
              (if (exists check-file-name)
                  (process-file entry.path check-file-name frdf)
                  (print "Warning: no .meta file for" entry.path
                         "in directory" directory-name))))))))

(defn process-file [txt-path meta-path frdf]
  
  (defn read-data [text-path meta-path]
    (with [f (open text-path)] (setv t1 (.read f)))
    (with [f (open meta-path)] (setv t2 (.read f)))
    [t1 t2])
  
  (defn modify-entity-names [ename]
    (.replace ename "the " ""))
  
  (setv [txt meta] (read-data txt-path meta-path))
  (setv entities (find-entities-in-text txt))
  (setv entities ;; only operate on a few entity types
        (lfor [e t] entities
              :if (in t ["NORP" "ORG" "PRODUCT" "GPE" "PERSON" "LOC"])
              [(modify-entity-names e) t]))
  (Data2Rdf meta entities frdf))
        


(process-directory "test_data" "output.rdf")

;;(setv v [["European" "NORP"] ["Portuguese" "NORP"] ["Banco Espirito Santo SA" "ORG"] ["last\nweek" "DATE"] ["Banco Espirito\n" "ORG"] ["December" "DATE"] ["The Wall\nStreet Journal" "ORG"] ["Thursday" "DATE"] ["Banco Espirito Santo's" "ORG"] ["Coke" "PRODUCT"] ["IBM" "ORG"] ["Canada" "GPE"] ["France" "GPE"] ["the Australian Broadcasting Corporation" "ORG"] ["Australian Broadcasting Corporation" "ORG"] ["Story" "PERSON"] ["Frank Munoz" "PERSON"] ["the Australian Writers Guild" "ORG"] ["the American University" "ORG"]])
