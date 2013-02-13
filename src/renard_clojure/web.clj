(ns renard-clojure.web
	(:use compojure.core)
	(:use ring.middleware.json-params)
	(:use renard-clojure.osc-server)
	(:use pl.danieljanus.jsonrpc))

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


(defn-json-rpc getMusicList []
	())

(defn-json-rpc getLightList []
	())


(defn-json-rpc getMusicLightList []
	())

(defn-json-rpc playMusic [song-id]
	())

(defn-json-rpc runLights [light-id]
	())

(defn-json-rpc playMusicWithLights [song-id, light-id]
	())

(defn-json-rpc changeLightChannels [light-channel-vals]
	())

(def server (make-osc-server "renard" 44100))

(add-fader-handles server)


(defn json-response [data & [status]]
	{:status (or status 200)
	 :headers {"Content-Type" "application/json"}
	 :body (json/write-str data)})

(defroutes handler
	(GET "/" []
		(json-response channel-vals))

	(PUT "/json-rpc" [req]
		(process-json-rpc req)))

(def app
	(-> handler
		wrap-json-params))