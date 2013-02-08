(ns renard-clojure.web
	(:use compojure.core)
	(:use ring.middleware.json-params)
	(:use renard-clojure.osc-server))

(require '[clojure.data.json :as json])
(use 'overtone.osc)
; (def renard-channel-map (loop [n 1 result {}]
;         (if (> n 32)
;           result
;           (recur (+ n 1) (merge result {(str "/Renard/fader" n) 0})))))

(def channel-vals (vec (for [x (range 1 33)] 0)))

;(def renard-channel-map (apply merge (for [x (range 1 33)] {x 0})))

(defn add-fader-handles [server]
	(for [x (range 1 33)]
		(osc-handle 
			server 
			(str "/Renard/fader" x)
			(fn [msg]
				(do
					(def channel-vals (assoc channel-vals (- x 1) (int (first (:args msg)))))
					(println channel-vals)
				)))))

; (defn add-renard-handles [server]
;   (dotimes [n 33] (osc-handle server (str "/Renard/fader" n)
;                               (fn [msg]
;                                 (do
;                                   (def renard-channel-map
;                                     (assoc renard-channel-map (str "/Renard/fader" n) (int (first (:args msg)))))
;                                   (println (vals renard-channel-map)))))))


(def server (make-osc-server "renard" 44100))

(add-fader-handles server)


(defn json-response [data & [status]]
	{:status (or status 200)
	 :headers {"Content-Type" "application/json"}
	 :body (json/write-str data)})

(defroutes handler
	(GET "/" []
		(json-response channel-vals)))

(def app
	(-> handler
		wrap-json-params))