(defsystem "toml-protocol"
  :version "0.1.0"
  :description "CLOS TOML encode/decode protocol for cl-stack; implements serdes-protocol :toml"
  :author "egao1980"
  :license "MIT"
  :depends-on ("encoding-protocol" "serdes-protocol")
  :properties (:cl-repo (:ci (:with ("toml-backend-tomlet"))))
  :serial t
  :pathname "src"
  :components ((:file "package")
               (:file "conditions")
               (:file "protocol")
               (:file "serdes"))
  :in-order-to ((test-op (test-op "toml-protocol/tests"))))

(defsystem "toml-protocol/tests"
  :depends-on ("toml-protocol" "toml-backend-tomlet" "datetime-protocol" "rove")
  :pathname "tests"
  :serial t
  :components ((:file "package")
               (:file "protocol-test"))
  :perform (test-op (o c)
             (unless (symbol-call :rove :run c)
               (error "tests failed for ~A" (component-name c)))))
