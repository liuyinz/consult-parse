;;; consult-jq.el --- Live preview of "jq" queries using consult -*- lexical-binding: t -*-

;; Copyright (C) 2021 liuyinz

;; Author: liuyinz<liuyinz@gmail.com>
;; Maintainer: liuyinz<liuyinz@gmail.com>
;; Created: 2021-10-06 18:49:13
;; Version: 0.1.0
;; Package-Requires: ((emacs "27") (consult "0.9"))
;; Homepage: https://github.com/liuyinz/consult-jq

;; This file is not a part of GNU Emacsl.

;; This program is free software; you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation, either version 3 of the License, or
;; (at your option) any later version.

;; This program is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.

;; You should have received a copy of the GNU General Public License
;; along with this program.  If not, see <https://www.gnu.org/licenses/>.

;;; Commentary:
;; "jq" binary installed

;;; Code:

(require 'consult)


(defcustom consult-jq-json-buffer-mode 'js-mode
  "Major mode for the resulting `consult-jq-buffer' buffer."
  :type '(function)
  :require 'consult-jq
  :group 'consult-jq)

(defcustom consult-jq-command "jq"
  "Command for `consult-jq'."
  :type '(string)
  :group 'consult-jq)

(defcustom consult-jq-buffer "*jq-json*"
  "Buffer for the `consult-jq' query results."
  :type '(string)
  :group 'consult-jq)

(defun consult--jq-builder (input)
  "Build jq command given INPUT."
  (list :command
    (append consult-jq-command (list "-M") input)))

(defun consult--jq-json (&optional query)
  (interactive)
  "Call 'jq' with the QUERY with a default of '.'."
  (with-current-buffer (window-buffer (minibuffer-selected-window))
    (call-process-region
     (point-min)
     (point-max)
     consult-jq-command
     nil
     consult-jq-buffer
     nil
     "-M"
     (or query "."))))

(defun consult--jq-format (input)
  "Wrapper function passing INPUT over to `consult-jq-json'."
  (when (get-buffer consult-jq-buffer)
    (with-current-buffer consult-jq-buffer
      (funcall consult-jq-json-buffer-mode)
      (erase-buffer)))
  (consult-jq-json input)
  (split-string
   (replace-regexp-in-string
    "\n$" ""
    (with-current-buffer consult-jq-buffer
      (buffer-string))) "\n"))

;; ;;;###autoload
;; (defun consult-jq ()
;;   "Consult interface for dynamically querying jq.
;; Whenever you're happy with the query, hit RET and the results
;; will be displayed to you in the buffer in `consult-jq-buffer'."
;;   (interactive)
;;   (ivy-read "jq query: " #'consult-jq-query-function
;;             :action #'(1
;;                        ("s" (lambda (_)
;;                               (display-buffer consult-jq-buffer))
;;                         "show"))
;;             :initial-input "."
;;             :dynamic-collection t
;;             :caller 'consult-jq))

;;;###autoload
(defun consult-jq ()
  "Consult interface for dynamically querying jq.
Whenever you're happy with the query, hit RET and the results
will be displayed to you in the buffer in `consult-jq-buffer'."
  (interactive)
  (consult--read
   (consult--async-command consult--jq-builder
     (consult--jq-format)
     :file-handler t)
   :prompt "jq query: "
   :initial "."
   ))


(provide 'consult-jq)
;;; consult-jq.el ends here
