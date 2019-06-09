(require 'package)
(add-to-list 'load-path "~/.emacs.d/elpa")
(add-to-list 'load-path "~/.emacs.d/lisp")
(setq package-archives '(("gnu" . "http://elpa.gnu.org/packages/")
                         ("melpa" . "http://melpa.milkbox.net/packages/")))
(package-initialize)

(print (mapcar #'(lambda (x) (package-install x)) '(alert async company company-coq company-math f font-utils magit ivy ivy-pass haskell-mode org-alert org-bullets paredit password-store pinentry plan9-theme proof-general rainbow-delimiters scala-mode tao-theme undo-tree with-editor unicode-fonts yasnippet)))
