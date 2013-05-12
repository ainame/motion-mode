;;; motion-mode.el --- major mode for RubyMotion enviroment

;; Copyright (C) 2013 by Satoshi Namai

;; Author: Satoshi Namai
;; URL: https://github.com/ainame/motion-mode
;; Version: 0.3.1
;; Package-Requires: ((flymake-easy "0.7") (flymake-cursor "1.0.2"))

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

(defcustom motion-flymake t
  "motion-flymake variable is the flag which whether your emacs open rubymotion-source with flymake-mode or don't"
  :type 'boolean
  :group 'motion-mode)

(defvar motion-execute-rake-buffer "motion-rake")
(defvar motion-convert-code-command
  (format "ruby %s" (concat (file-name-directory load-file-name) "bin/code_converter.rb")))

(defun motion-project-root ()
  (let ((root (locate-dominating-file default-directory "Rakefile")))
    (when root
      (expand-file-name root))))

(defun motion-project-p ()
  (let ((root (motion-project-root)))
    (when root
      (let ((rakefile (concat root "Rakefile")))
        (when (file-exists-p rakefile)
          (with-temp-buffer
	    (insert-file-contents rakefile)
            (goto-char (point-min))
            (search-forward "Motion::Project::App" nil t)))))))

;;;###autoload
(define-derived-mode motion-mode
  ruby-mode
  "RMo"
  "motion-mode is provide a iOS SDK's dictonary for auto-complete-mode"
  (progn
    (when (eq motion-flymake t)
      (motion-flymake-init))))

;;;###autoload
(defun motion-recognize-project ()
  (interactive)
  (when (and (eq major-mode 'ruby-mode) (motion-project-p))
    (motion-mode)))

(defun motion-get-rake-sub-command ()
  (if current-prefix-arg
      (read-string "Command: rake ")))

(defun motion-execute-rake-command ()
  (let ((sub-command (motion-get-rake-sub-command))
	(buf (get-buffer-create (concat "*" motion-execute-rake-buffer "*"))))
    (if (equal sub-command nil)
	(progn
	  (message "rake")
	  (pop-to-buffer (make-comint motion-execute-rake-buffer "rake")))
      (progn
	(message (concat  "rake " sub-command))
	(pop-to-buffer (make-comint motion-execute-rake-buffer "rake" nil sub-command))))))

;;;###autoload
(defun motion-execute-rake ()
  (interactive)
  (let ((root (motion-project-root)))
    (if (not root)
        (message "Here is not Ruby Motion Project")
      (let ((default-directory root))
	(motion-execute-rake-command)))))

(defun motion-flymake-init ()
  (progn
    (require 'flymake-easy)
    (require 'flymake-cursor)

    (defconst flymake-motion-err-line-patterns
      '(("^\\(.*\.rb\\):\\([0-9]+\\): \\(.*\\)$" 1 2 nil 3)))

    (defvar flymake-motion-executable "/Library/RubyMotion/bin/ruby"
      "The macruby executable to use for syntax checking.")

    ;; Invoke rubymotion with '-c' to get syntax checking
    (defun flymake-motion-command (filename)
      "Construct a command that flymake can use to check ruby-motion source."
      (list flymake-motion-executable "-w" "-c" filename))
    
    (defun flymake-motion-load ()
      "Configure flymake mode to check the current buffer's macruby syntax."
      (interactive)
      (flymake-easy-load 'flymake-motion-command
			 flymake-motion-err-line-patterns
			 'tempdir
			 "rb"))
    (custom-set-variables
     '(help-at-pt-timer-delay 0.3)
     '(help-at-pt-display-when-idle '(flymake-overlay)))
    (flymake-motion-load)
    ))

;;;###autoload
(defun motion-dash-at-point ()
  "This function open document by Dash.app."
  (interactive)
  (let ((keyword (thing-at-point 'word)))
    (princ keyword)
    (shell-command (format "open dash://rubymotion:%s" keyword))))

;;;###autoload
(defun motion-convert-code-region (start end)
  "convert code from Objective-C to RubyMotion.
This is inspired from https://github.com/kyamaguchi/SublimeObjC2RubyMotion.
"
  (interactive (list (region-beginning) (region-end)))
  (shell-command-on-region start end motion-convert-code-command nil t))

(provide 'motion-mode)
;;; motion-mode.el ends here
