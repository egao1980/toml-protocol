(in-package #:toml-protocol/tests)

(deftest toml-roundtrip-config-shape
  (let* ((text "
features = [\"auth\", \"cache\"]

[database]
host = \"localhost\"
port = 5432
enabled = true
")
         (ht (decode text)))
    (ok (hash-table-p ht))
    (ok (equalp #("auth" "cache") (gethash "features" ht)))
    (let ((db (gethash "database" ht)))
      (ok (string= "localhost" (gethash "host" db)))
      (ok (= 5432 (gethash "port" db)))
      (ok (eq t (gethash "enabled" db))))
    (let ((again (decode (encode ht))))
      (ok (string= "localhost" (gethash "host" (gethash "database" again))))
      (ok (= 5432 (gethash "port" (gethash "database" again)))))))

(deftest toml-octets
  (let* ((ht (decode "k = \"v\""))
         (oct (encode-to-octets ht)))
    (ok (typep oct '(vector (unsigned-byte 8))))
    (ok (string= "v" (gethash "k" (decode-octets oct))))))

(deftest toml-false-true
  (let ((ht (decode "on = true
off = false
")))
    (ok (eq t (gethash "on" ht)))
    (ok (eq nil (gethash "off" ht)))))

(deftest toml-pathname
  (uiop:with-temporary-file (:pathname path :prefix "toml-protocol-" :type "toml" :keep t)
    (with-open-file (out path :direction :output :if-exists :supersede)
      (write-string "n = 1
" out))
    (ok (= 1 (gethash "n" (decode path))))))

(deftest toml-datetimes
  (let ((ht (decode "
odt = 1979-05-27T07:32:00Z
ldt = 1979-05-27T07:32:00
ld = 1979-05-27
lt = 07:32:00
")))
    (ok (datetime-protocol:zoned-moment-p (gethash "odt" ht)))
    (ok (datetime-protocol:momentp (gethash "ldt" ht)))
    (ok (datetime-protocol:datep (gethash "ld" ht)))
    (ok (datetime-protocol:time-of-day-p (gethash "lt" ht)))
    (let ((again (decode (encode ht))))
      (ok (datetime-protocol:zoned-moment-p (gethash "odt" again)))
      (ok (datetime-protocol:datep (gethash "ld" again))))))

(deftest toml-serdes
  (let ((ht (serdes-protocol:decode "k = 1" :format :toml)))
    (ok (= 1 (gethash "k" ht)))
    (ok (search "k" (serdes-protocol:encode ht :format :toml)))))
