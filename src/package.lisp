(defpackage #:toml-protocol
  (:use #:cl)
  (:nicknames #:stack-toml)
  (:export #:toml-error
           #:toml-parse-error
           #:toml-encode-error
           #:toml-error-message

           #:*toml-backend*
           #:toml-backend
           #:backend-encode
           #:backend-decode
           #:encode
           #:decode
           #:encode-to-octets
           #:decode-octets

           #:null-p
           #:true-p
           #:false-p

           #:toml-serdes-backend
           #:make-toml-serdes-backend
           #:use-toml-serdes-backend
           #:install-serdes-toml-hooks))

(in-package #:toml-protocol)
