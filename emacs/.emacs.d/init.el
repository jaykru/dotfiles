;; enable MELPA
(require 'package)
  (add-to-list 'load-path "~/.emacs.d/elpa")
  (add-to-list 'load-path "~/.emacs.d/lisp")
  (setq package-archives '(("gnu" . "http://elpa.gnu.org/packages/")
			   ("melpa" . "http://melpa.milkbox.net/packages/")))
  (setq package-selected-packages '(cargo
				    racer
				    magit-topgit
				    unicode-fonts
				    undo-tree
				    tuareg
				    tao-theme
				    scala-mode
				    rainbow-delimiters
				    proof-general
				    plan9-theme
				    pinentry
				    pareditq
				    org-bullets
				    org-alert
				    notmuch
				    nix-mode
				    markdown-mode
				    magit
				    ivy-pass
				    haskell-mode
				    edit-indirect
				    company-coq
				    magit-todos
				    geiser
				    visual-regexp
				    sml-mode
				    slime
				    rustic
				    rust-mode
				    racket-mode
				    quelpa-use-package
				    quasi-monochrome-theme
				    org-pomodoro
				    moe-theme
				    matrix-client
				    magit-popup
				    latex-preview-pane
				    ivy
				    go-mode
				    forge
				    flycheck
				    expand-region
				    exec-path-from-shell
				    eglot
				    color-theme-sanityinc-tomorrow
				    autotetris-mode
				    auto-complete))
  (package-initialize)
  (package-install-selected-packages)

(global-set-key (kbd "C-x g") 'magit-status)
(global-unset-key (kbd "C-z"))

;; org stuff
(global-set-key "\C-cl" 'org-store-link)
(global-set-key "\C-ca" 'org-agenda)
(global-set-key "\C-cc" 'org-capture)
(global-set-key "\C-cb" 'org-iswitchb)

;; highlight delims
(setq show-paren-delay 0)
(show-paren-mode 1)

;; line numbers
(global-linum-mode)

;; quiet, you.
(setq ring-bell-function 'ignore)

;; ivy
(ivy-mode t)
(setq ivy-use-virtual-buffers t) (setq ivy-count-format "(%d/%d) ")

;; column numbers
(column-number-mode t)

;  (unicode-fonts-setup)
(let ((my-frame-font
      (if (eq system-type 'darwin)
            "Menlo"
	    "Iosevka")))
     (setq default-frame-alist
           `((font . ,my-frame-font)
             (vertical-scroll-bars . nil)
   	     (horizontal-scroll-bars . nil)
	     (tool-bar-lines . 0)
	     (menu-bar-lines . 0))))

;; load theme
(setq tao-theme-use-sepia t)
(setq tao-theme-sepia-depth 3)
(setq tao-theme-sepia-saturation 1.10)
(load-theme 'tao-yin t)

;; tramp for sudo access
(require 'tramp)
(setq tramp-default-method "ssh")
(set-default 'tramp-default-proxies-alist (quote ((".*" "\\`root\\'" "/ssh:%h:"))))
(defun sudo-edit-current-file ()
  (interactive)
  (let ((position (point)))
    (find-alternate-file
     (if (file-remote-p (buffer-file-name))
         (let ((vec (tramp-dissect-file-name (buffer-file-name))))
           (tramp-make-tramp-file-name
            "sudo"
            (tramp-file-name-user vec)
            (tramp-file-name-host vec)
            (tramp-file-name-localname vec)))
       (concat "/sudo:root@localhost:" (buffer-file-name))))
    (goto-char position)))

(require 'em-smart)
(setq eshell-where-to-jump 'begin)
(setq eshell-review-quick-commands nil)
(setq eshell-smart-space-goes-to-end t)

(setq epa-pinentry-mode 'loopback)
(pinentry-start)

;; this needs to happen early because other part of the config depend
;; on PATH being set correctly.
(when (eq system-type 'darwin)
    (exec-path-from-shell-initialize)
    (setq mac-command-modifier 'meta))

(load-file (let ((coding-system-for-read 'utf-8))
             (shell-command-to-string "agda-mode locate")))
(require 'agda2-mode)

(add-hook 'prog-mode-hook
	  (lambda ()
	    (progn
	      (rainbow-delimiters-mode t)
	      (electric-indent-mode 'f))))

(require 'haskell-mode)
(require 'haskell-interactive-mode)
(require 'haskell-process)
;; can't use add-hook for some reason, but this works.
(add-hook 'haskell-mode-hook #'(lambda ()
                                (progn (interactive-haskell-mode)
				       (haskell-indentation mode))))

(add-hook 'rust-mode-hook #'(lambda ()
                             (progn 
			      (racer-mode)
			      (cargo-minor-mode))))
(add-hook 'racer-mode-hook #'(lambda ()
                              (progn
			        (eldoc-mode t)
				(company-mode t))))
;(define-key rust-mode-map (kbd "TAB") #'company-indent-or-complete-common)
(setq company-tooltip-align-annotations t)

(add-hook 'emacs-lisp-mode-hook
	  (lambda ()
	    (paredit-mode t)))

(defun my-asm-mode-hook ()
  ;; you can use `comment-dwim' (M-;) for this kind of behaviour anyway
  (local-unset-key (vector asm-comment-char))
  ;; asm-mode sets it locally to nil, to "stay closer to the old TAB behaviour".
  (setq tab-always-indent (default-value 'tab-always-indent)))

(add-hook 'asm-mode-hook #'my-asm-mode-hook)

;; unicode bullets
(require 'org-bullets)
(add-hook 'org-mode-hook (lambda () (org-bullets-mode 1)))

;; todo keywords
(setq org-todo-keywords
      '((sequence "TODO(t)" "|" "DONE(d)")
        (sequence "|" "CANCELED(c)")
        (sequence "WAIT(w)" "|")))

;; todo keyword faces
(setq org-todo-keyword-faces
       '(("TODO". (:foreground "red" :background "#fedfe1" :box '(:line-width 1 :style released-button)))
        ("DONE". (:foreground "#40883f" :background "#A8D8B9" :box '(:line-width 1 :style released-button)))
        ("WAIT" . (:foreground "orange" :background "#FFF689" :box '(:line-width 1 :style released-button)))
        ("CANCELED" . (:foreground "black" :strike-through t :background "#d8d7da" :box '(:line-width 1 :style released-button)))))

;; alerts
(require 'org-alert)
(require 'alert)
(setq alert-default-style 'notifier)
(org-alert-enable)
(setq org-alert-interval 21600)

(setq org-format-latex-options (plist-put org-format-latex-options :scale 2.0))

;; preserve clocks between sessions
(setq org-clock-persist 'history)
(org-clock-persistence-insinuate)

(setq pdf-latex-command "luatex") ; ad fontes! :)
(setq preview-scale-function 2.0)

(setq coq-prog-name "coqtop")
(add-hook 'coq-mode-hook
	  (lambda ()
	    (progn
	    (company-coq-mode t)
	    (rainbow-delimiters-mode t))))

;; (setq sendmail-program (concat (getenv "HOME") "/bin/msmtpq"))
(setq send-mail-function 'sendmail-send-it
      sendmail-program "msmtp"
      mail-specify-envelope-from t
      message-sendmail-envelope-from 'header
      mail-envelope-from 'header
      mail-host-address "kamisama")

;; company address completion
(add-hook 'notmuch-mode-hook
   (lambda ()
      (progn
	(company-mode t))))

;; notmuch saved queries
(setq notmuch-saved-searches
'(
  (:name "inbox" :query "(date:month.. and not to:@sifive.com and not tag:sent) and (not tag:sent)" :key "i")
  (:name "work" :query "to:sifive.com and not [JIRA]" :key "w")
  (:name "banking"
   :query "(from:Chase or from:PNC or from:\"Discover Card\")"
   :key "b")
  (:name "unread" :query "tag:unread" :key "u")
  (:name "flagged" :query "tag:flagged" :key "f")
  (:name "sent" :query "tag:sent" :key "t")
  (:name "drafts" :query "tag:draft" :key "d")
  (:name "all mail" :query "*" :key "a")
 ))

(setq multi-term-program "/run/current-system/sw/bin/bash")

(setq browse-url-browser-function 'browse-url-generic
      browse-url-generic-program (if (eq system-type 'darwin)
                                     "open"
				     "brave"))

(display-battery-mode)
