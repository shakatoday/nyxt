;;;; SPDX-FileCopyrightText: Atlas Engineer LLC
;;;; SPDX-License-Identifier: BSD-3-Clause

(in-package :nyxt/tests)

(plan nil)

(define-class test-profile (nosave-profile)
  ((nfiles:name :initform "test"))
  (:documentation "Test profile that does not read nor write to disk."))

(defmethod nfiles:read-file ((profile test-profile) (file nyxt-file) &key &allow-other-keys)
  "This method guarantees FILE will not be loaded from disk in TEST-PROFILE."
  nil)

(subtest "Global history"
  (let* ((*browser* (make-instance 'browser)))
    ;; Set profile to nosave to inhibit serialization / deserialization.
    ;; TODO: We should still test serialization and deserialization.
    (setf *global-profile* (make-instance 'test-profile))
    (let ((buffer (nyxt::make-buffer)))
      (nyxt:with-current-buffer buffer
        (let ((file (history-file buffer)))
          (nyxt::history-add (quri:uri "http://example.org"))
          (is (length (htree:all-data (nfiles:content file)))
              1
              "history has 1 entry")
          (let ((entry (first (htree:all-data (nfiles:content file)))))
            (is (url entry)
                (quri:uri "http://example.org")
                :test #'quri:uri=
                "value has quri:uri")
            (is (title entry)
                ""
                "value has no title"))
          (nyxt::history-add (quri:uri "http://example.org") :title "foo")
          (is (length (htree:all-data (nfiles:content file)))
              1
              "history has still 1 entry after adding same URL")
          (is (nyxt::implicit-visits (first (htree:all-data (nfiles:content file))))
              2)
          (let ((entry (first (htree:all-data (nfiles:content file)))))
            (is (title entry)
                "foo"
                "value now has title"))
          (nyxt::history-add (quri:uri "http://example.org/sub"))
          (is (length (htree:all-data (nfiles:content file)))
              2
              "history now has 2 entries")
          (uiop:delete-file-if-exists (nfiles:expand (history-file buffer))))))))

(finalize)
