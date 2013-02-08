(ns renard-clojure.core
  (:require [clj-http.client :as client]))

(use 'serial-port)
(require '[clojure.data.json :as json])


(def cm (clj-http.conn-mgr/make-reusable-conn-manager {:timeout 10 :threads 1}))


;to avoid having to use two-byte protocol version,
;instead, replace reserved channel values with nearby values
(defn package-values [channel-values]
    (replace {0x7d 0x7c 0x7e 0x7c 0x7f 0x80} channel-values))


(defn create-packets [pkg channel-count]
  (loop [x (quot (count pkg) channel-count) rpkg pkg result []]
    (if (>= x 0)
      (recur (- x 1) (drop channel-count rpkg) (concat result [(int 0x7e) (int 0x80)] (take channel-count rpkg)))
      result)))


;pad every n values so that micro controller doesn't get behind
(defn insert-padding [pkg n]
  (if (> n (count pkg))
    pkg
    (loop [x (quot (count pkg) n) rpkg pkg result []]
     (if (> x 0)
      (recur (- x 1) (drop n rpkg) (concat result (take n rpkg) '((int 0x7f))))
      result))))

;package the channel-values into packets of size channel-count and place a pad byte every n bytes
(defn pack-n-pad [channel-values n channel-count]
  (insert-padding (create-packets (package-values channel-values) channel-count) n))

(defn renard-open-port [port]
  (open port 38400))

(defn renard-close-port [port]
  (close port))

;write data to port
(defn renard-write [data port]
  (let [d (pack-n-pad data 100 32)]
    (write port (byte-array (count d) (map #(.byteValue %) d)))))


(def port (renard-open-port "COM28"))


(defn run-lights []
  (while true
  (do
    (def b (client/get "http://107.22.230.121:50000" {:connection-manager cm :as :json}))
    (def v (get b :body))
    (renard-write v port)
    (Thread/sleep 2000))))






