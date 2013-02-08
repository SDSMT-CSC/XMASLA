(ns renard-clojure.osc-server
  (:use [renard-clojure.core]))

(require '[clojure.data.json :as json])
(use 'overtone.osc)

;(def renard-out :temp)
;(def port (renard-open-port "COM28"))

(def channel-map (loop [n 1 result {}]
        (if (> n 32)
          result
          (recur (+ n 1) (merge result {(str "/Renard/fader" n) 0})))))

;(zero-conf-on)

(defn make-osc-server [name port]
  (osc-server port name))





(defn add-osc-handles [server]
  (dotimes [n 33] (osc-handle server (str "/Renard/fader" n)
                              (fn [msg]
                                (do
                                  (def channel-map
                                    (assoc channel-map (str "/Renard/fader" n) (int (first (:args msg)))))
                                  (println (vals channel-map))
                                )))))

(defn remove-osc-handles [server]
  (osc-rm-all-handlers server "/Renard"))

(defn close-osc-server [server] (osc-close server))



;(def server (make-osc-server "renard" 44100))

;(add-osc-handles server)



