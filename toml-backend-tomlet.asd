(defsystem "toml-backend-tomlet"
  :version "0.1.0"
  :description "toml-protocol backend — tomlet decode + first-party emit"
  :author "egao1980"
  :license "MIT"
  :depends-on ("toml-protocol" "tomlet" "datetime-protocol" "encoding-protocol")
  :serial t
  :pathname "src/backend-tomlet"
  :components ((:file "package")
               (:file "emitter")
               (:file "backend")))
