# motion-mode
## Description

The motion-mode provides some convenient features when you write codes in RubyMotion.
The features are the following:

* Recognize RubyMotion projects
  * You can open *.rb files by motion-mode in RubyMotion projects.
* Syntax Highlight by ruby-mode
* Code completion of defined words by [auto-complete-mode](http://github.com/auto-complete/auto-complete)
  * You can make a dictionary with make_dict.rb which includes this repository.
* Execution of rake tasks in Emacs
  * You can execute all rake tasks in Emacs with prefix keybinds
* In particular, support operation of interactive-debugger in emacs by comint-mode
  * When you execute a rake task by motion-execute-rake, it executes 'rake' in default that is build command.
* Syntax check by flymake-mode
  * The flymake-mode is the default syntax - check feature in Emacs.
  * Support it in motion-mode by macruby interpreter.
* Document search by Dash.app
  * Dash.app is a convenient document tool which supports RubyMotion's one.
  * When you want search documents by keywords on emacs's cursol, you can use motion-dash-at-point.
* Code converter to convert a part of code from Objective-C to Ruby-style sentence

The motion-mode provides some convenient commands(motion-execute-rake, motion-dash-at-point, etc...),
but the motion-mode dosen't provide key-binds. You can setup key-binds as you like.

## Install

Write the following codes in your init.el

```el
(require 'package)
(dolist (archive '(("melpa" . "http://melpa.milkbox.net/packages/")))
  (add-to-list 'package-archives archive :append))
(package-initialize)

(when (null package-archive-contents)
  (package-refresh-contents))

(defvar my-packages '(motion-mode
                      some-other-cool-mode
                      moar-modes
                      ...))

(dolist (p my-packages)
  (when (not (package-installed-p p))
    (package-install p)))
```

and then:

<kbd>M-x package-install</kbd>

## Usage

Change to the appropriate directory:

``` sh
$ cd ~/.emacs.d/elpa/motion-mode-YYYYMMDD.233 # <- the suffix will be different on your machine
```

and then:

```
$ iOS=7.1 # <-- set this to your requirements
$ HEADERS_PATH=$(xcode-select -print-path)/Platforms/iPhoneOS.platform/Developer/SDKs/iPhoneOS${iOS}.sdk/System/Library/Frameworks
$ find ${HEADERS_PATH} -name "*.h" | xargs ruby bin/make_dict.rb
$ cp ./motion-mode ~/.emacs.d/ac-dict
$ emacs ~/.emacs.d/init.el
```

If you're installing your packages manually, and **didn't** follow the
advice above in the **Install** section, add following settings:

```el
(add-to-list 'load-path "~/.emacs.d/elisp/some-dir-of-your-choice/motion-mode") # <-- check this path
(require 'motion-mode)
```

Regardless how you've installed `motion-mode`, add these settings:

```el
;; following add-hook is very important.
(add-hook 'ruby-mode-hook 'motion-recognize-project)
(add-to-list 'ac-modes 'motion-mode)
(add-to-list 'ac-sources 'ac-source-dictionary)
;; set key-binds as you like
(define-key motion-mode-map (kbd "C-c C-c") 'motion-execute-rake)
(define-key motion-mode-map (kbd "C-c C-d") 'motion-dash-at-point)
```

## Commands

You can set key-binds of the following commands. The motion-mode
doesn't provide default key bindings.

* motion-execute-rake
  * Execution of rake tasks in Emacs
* motion-dash-at-point
  * Document search by Dash.app
* motion-convert-code-region
  * Code converter to convert a part of code from Objective-C to Ruby-style sentence

### Setting Example

```el
(define-key motion-mode-map (kbd "C-c C-c") 'motion-execute-rake)
(define-key motion-mode-map (kbd "C-c C-d") (lambda () (interactive) (motion-execute-rake-command "device")))
(define-key motion-mode-map (kbd "C-c C-o") 'motion-dash-at-point)
(define-key motion-mode-map (kbd "C-c C-p") 'motion-convert-code-region)
```

## Function
* motion-execute-rake-command TASK
  * execute rake task of TASK

## Variable
* motion-flymake (default is t)
  * The motion-flymake variable is the flag which your emacs opens rubymotion-source with flymake-mode or not.

## See Also
* make_dict.rb cite from [roupam/yasobjc](https://github.com/roupam/yasobjc).
* code_conveter.rb cite from [kyamaguchi/SublimeObjC2RubyMotion](https://github.com/kyamaguchi/SublimeObjC2RubyMotion)
