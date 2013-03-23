;;; motion-mode.el --- major mode for RubyMotion enviroment

;; Copyright (C) 2013 by Satoshi Namai

;; Author: Satoshi Namai
;; URL: https://github.com/ainame/motion-mode
;; Version: 0.1

;; Copyright (C) 2013 by Satoshi Namai <s.namai.2012 at gmail.com>
;; 
;; Permission is hereby granted, free of charge, to any person
;; obtaining a copy of this software and associated documentation
;; files, to deal in the Software without restriction, including
;; without limitation the rights to use, copy, modify, merge, publish,
;; distribute, sublicense, and/or sell copies of the Software, and to
;; permit persons to whom the Software is furnished to do so, subject
;; to the following conditions:
;; 
;; The above copyright notice and this permission notice shall be
;; included in all copies or substantial portions of the Software.
;; 
;; THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
;; EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
;; MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
;; NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS
;; BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN
;; ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
;; CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
;; SOFTWARE.

;;; Commentary:

;;; Code:

(defvar motion-execute-rake-buffer "*motion-rake*")

(defun motion-project-root ()
  (let ((root (locate-dominating-file default-directory "Rakefile")))
    (when root
      (expand-file-name root))))

(defun motion-project-p ()
  (let ((root (motion-project-root)))
    (when root
      (let ((rakefile (concat root "Rakefile")))
        (when (file-exists-p rakefile)
          (with-current-buffer (find-file-noselect rakefile)
            (goto-char (point-min))
            (search-forward "Motion::Project::App" nil t)))))))

;;;###autoload
(define-derived-mode motion-mode
  ruby-mode
  "RMo"
  "motion-mode is provide a iOS SDK's dictonary for auto-complete-mode")

;;;###autoload
(defun motion-upgrade-major-mode-if-motion-project ()
  (interactive)
  (when (and (eq major-mode 'ruby-mode) (motion-project-p))
    (motion-mode)))

(defun motion-execute-rake-command ()
  (if (not current-prefix-arg)
      "rake"
    (read-string "Command: " "rake " nil "rake")))

;;;###autoload
(defun motion-execute-rake ()
  (interactive)
  (let ((root (motion-project-root)))
    (if (not root)
        (message "Here is not Ruby Motion Project")
      (let ((default-directory root)
            (buf (get-buffer-create motion-execute-rake-buffer))
            (cmd (motion-execute-rake-command)))
        (with-current-buffer buf
          (erase-buffer)
          (call-process-shell-command cmd nil t)
          (pop-to-buffer buf))))))

(provide 'motion-mode)
;;; motion-mode.el ends here
