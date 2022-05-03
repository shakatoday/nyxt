(in-package :cl-user)

(cffi:load-foreign-library "libwebkit2gtk-4.1.so")

(cffi:defcallback hello :void ()
  (format t "Hello there!"))

(sb-alien:define-alien-callable inject-js-world-function int ()
  (g:g-signal-connect
   (webkit:webkit-script-world-get-default) "window-object-cleared"
   (lambda (world page frame)
     (declare (ignorable page))
     (webkit::%make-jsc-function (webkit:webkit-frame-get-javascript-context-for-script-world frame world)
                                 "hello" (cffi:callback hello) 0))))

(sb-alien:define-alien-callable inject-js-world-function int ()
  (format t "Hello!"))
