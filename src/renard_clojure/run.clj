(ns renard-clojure.run
	(:gen-class))

(use 'ring.adapter.jetty)
(require '[renard-clojure.web :as web])

(defn -main [& args]
	(run-jetty #'web/app {:port 50000}))

(defn start-app []
	(do
		(web/add-fader-handles web/server)
		(run-jetty #'web/app {:port 50000})))