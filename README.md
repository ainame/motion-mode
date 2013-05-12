# motion-mode
## Description

The motion-mode provide some convinience features when you write code in RubyMotion.
The features is following this:

* Recognize RubyMotion projects
  * You can open *.rb files by motion-mode in RubyMotion projects.
* Syntax Highlight by ruby-mode
* Code completion of defined words by [auto-complete-mode](http://github.com/auto-complete/auto-complete)
  * You can maek dictonary with make_dict.rb which include this repository.
* Execution of rake tasks in Emacs
  * You can execute all rake tasks in Emacs with prefix keybinds
* In particular, support operation of interactive-debugger in emacs by comint-mode
  * When you execute a rake task by motion-execute-rake, it execute 'rake' in default that is build command.
* Syntax check by flymake-mode
  * The flymake-mode is default syntax check feature in Emacs.
  * Support it in motion-mode by macruby interpreter.
* Document search by Dash.app
  * Dash.app is convinience document tool which support Rubymeotion' one.
  * When you want search document by keyword on emacs's cursol, you can use motion-dash-at-point.
* Code converter to convert a part of code from Objective-C to Ruby style sentence

The motion-mode provides some convinience commands(motion-execute-rake, motion-dash-at-point, etc...),
but the motion-mode dosen't provide key-bindings. You can setting key-bindings as you like.

## Usage
```sh
$ cd ~/.emacs.d/elisp
$ git clone https://github.com/ainame/motion-mode.git
$ cd motion-mode
$ find /Applications/Xcode.app/Contents/Developer/Platforms/iPhoneOS.platform/Developer/SDKs/iPhoneOS6.1.sdk/System/Library/Frameworks -name "*.h" | xargs ruby bin/make_dict.rb
$ cp ./motion-mode ~/.emacs.d/ac-dict
$ emacs ~/.emacs.d/init.el # add following setting
(add-to-list 'load-path "~/.emacs.d/elisp/motion-mode")
(require 'motion-mode)
;; following adding of hook is very important.
(add-hook 'ruby-mode-hook 'motion-recognize-project)
(add-to-list 'ac-modes 'motion-mode)
(add-to-list 'ac-sources 'ac-source-dictionary)
;; set keybindings as you like
(define-key motion-mode-map (kbd "C-c C-c") 'motion-execute-rake)
(define-key motion-mode-map (kbd "C-c C-d") 'motion-dash-at-point)
```
## Commands
You can set key binding of following commands. The motion-mode dosen't provide default key bindings.

* motion-execute-rake
  * Execution of rake tasks in Emacs
* motion-dash-at-point
  * Document search by Dash.app
* motion-convert-code-region
  * Code converter to convert a part of code from Objective-C to Ruby style sentence

### Setting Example
```elisp
(define-key motion-mode-map (kbd "C-c C-c") 'motion-execute-rake)
(define-key motion-mode-map (kbd "C-c C-d") 'motion-dash-at-point)
(define-key motion-mode-map (kbd "C-c C-p") 'motion-convert-code-region)
```

## Variable
* motion-flymake (default is t)
  * motion-flymake variable is the flag which whether your emacs open rubymotion-source with flymake-mode or don't.

## See Also
* make_dict.rb cite from [roupam/yasobjc](https://github.com/roupam/yasobjc).
* code_conveter.rb cite from [kyamaguchi/SublimeObjC2RubyMotion](https://github.com/kyamaguchi/SublimeObjC2RubyMotion)
