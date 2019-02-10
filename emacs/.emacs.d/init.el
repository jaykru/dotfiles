;; enable MELPA
(require 'package)
(add-to-list 'load-path "~/.emacs.d/elpa")
(add-to-list 'load-path "~/.emacs.d/lisp")
(setq package-archives '(("gnu" . "http://elpa.gnu.org/packages/")
                         ("melpa" . "http://melpa.milkbox.net/packages/")))
(package-initialize)

(require 'expand-region)
(global-set-key (kbd "C-=") 'er/expand-region)
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

;; autocomplete
(global-auto-complete-mode t)

;; line numbers
(global-linum-mode)

;; quiet, you.
(setq ring-bell-function 'ignore)

;; ivy
(ivy-mode t)
(setq ivy-use-virtual-buffers t) (setq ivy-count-format "(%d/%d) ")

;; column numbers
(column-number-mode t)

(unicode-fonts-setup)
(set-frame-font "Menlo")
(setq default-frame-alist
<<<<<<< HEAD
      '((font . "Menlo")
	(vertical-scroll-bars . nil)
	(horizontal-scroll-bars . nil)
	(tool-bar-lines . 0)
	(menu-bar-lines . 0)
	;(left-fringe . 1)
	;(right-fringe . 1)
	))

(set-face-attribute 'default nil :height 120)

;; load theme
(setq tao-theme-use-sepia t)
(setq tao-theme-sepia-depth 3)
(setq tao-theme-sepia-saturation 1.10)
(load-theme 'plan9 t)
=======
      '((font . "Inconsolata")
        (vertical-scroll-bars . nil)
        (horizontal-scroll-bars . nil)
        (tool-bar-lines . 0)
        (menu-bar-lines . 0)
        (left-fringe . 1)
        (right-fringe . 1)))

(set-face-attribute 'default nil :height 110)

;; mark theme as safe
;; load it
(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(custom-safe-themes
   (quote
    ("0e0c37ee89f0213ce31205e9ae8bce1f93c9bcd81b1bcda0233061bb02c357a8" "c9e02bc73b027c25da6d5d3eee642f7892bb409a32acecd2ae8c7b5df52c068f" default)))
 '(package-selected-packages
   (quote
    (go-mode magit nix-mode znc wolfram w3m w3 visual-regexp tao-theme slime rust-mode rainbow-delimiters plan9-theme paredit org-bullets org-alert multi-term mingus latex-preview-pane ivy hledger-mode expand-region auto-complete))))
(load-theme 'plan9)
>>>>>>> a27dfe93902eabb50d2edddcdd0c845fe0deb2df

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

<<<<<<< HEAD
(exec-path-from-shell-initialize)

(add-to-list 'load-path "/usr/local/share/emacs/site-lisp/agda")
(require 'agda2-mode)
=======
;(exec-path-from-shell-initialize)
(setq epa-pinentry-mode 'loopback)
(pinentry-start)
>>>>>>> a27dfe93902eabb50d2edddcdd0c845fe0deb2df

(add-hook 'prog-mode-hook
	  (lambda ()
	    (progn
	      (rainbow-delimiters-mode t)
	      (global-undo-tree-mode t))))

;; cl mode
(require 'paredit)
(add-hook 'lisp-mode-hook
	  (lambda ()
	    (progn
	      (paredit-mode t)
	      (slime-mode))))

;; SLIME
(require 'slime)
(setq slime-contribs '(slime-fancy))
(add-hook 'slime-repl-mode-hook 
	  (lambda () (progn
		       (rainbow-delimiters-mode t)
		       (paredit-mode t))))
(setq inferior-lisp-program "sbcl")
(slime-setup '(slime-fancy))

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

<<<<<<< HEAD
;; preserve clocks between sessions
(setq org-clock-persist 'history)
(org-clock-persistence-insinuate)

(setq pdf-latex-command "luatex") ; ad fontes! :)

(setq coq-prog-name "coqtop")
(add-hook 'coq-mode-hook
	  (lambda ()
	    (progn
	    (company-coq-mode t)
	      (rainbow-delimiters-mode t))))

;(setq browse-url-browser-function 'browse-url-generic
;     browse-url-generic-program "Google\ Chrome.app")

(setq mac-command-modifier 'meta)
=======
(setq pdf-latex-command "lualatex") ; ab fontes :'(

(load "~/.emacs.d/lisp/PG/generic/proof-site")
;(add-hook 'coq-mode-hook (lambda () (proof-unicode-tokens-enable)))

(add-to-list 'load-path "/run/current-system/sw/share/emacs/site-lisp/mu4e")
(require 'mu4e)

;; default
(setq mu4e-maildir (expand-file-name "~/Maildir"))

(setq mu4e-maildir-shortcuts
   '(("/Reed/INBOX" . ?r)
     ("/iCloud/INBOX" . ?i)))

(setq mu4e-get-mail-command "offlineimap")

(require 'smtpmail)

(setq message-send-mail-function 'smtpmail-send-it
      starttls-use-gnutls t
      smtpmail-starttls-credentials
      '(("smtp.gmail.com" 587 nil nil))
      smtpmail-auth-credentials
      (expand-file-name "~/.authinfo.gpg")
      smtpmail-default-smtp-server "smtp.gmail.com"
      smtpmail-smtp-server "smtp.gmail.com"
      smtpmail-smtp-service 587
      smtpmail-debug-info t)

(add-hook 'mu4e-compose-mode-hook
          (defun cpb-compose-setup ()
            "Use hard newlines, so outgoing mails will have format=flowed."
            (use-hard-newlines t 'guess)))

(setq mu4e-contexts
 `( ,(make-mu4e-context
     :name "Reed"
     :match-func (lambda (msg) (when msg
       (string-prefix-p "/Reed" (mu4e-message-field msg :maildir))))
     :vars '(
       (mu4e-sent-folder . "/Reed/[Gmail].Sent Mail")
       (mu4e-drafts-folder . "/Reed/[Gmail].Drafts")
       (mu4e-trash-folder . "/Reed/[Gmail].Trash")
       (mu4e-refile-folder . "/Gmail/[Gmail].Archive")
       ( user-mail-address      . "kruerj@reed.edu"  )
       ( user-full-name         . "Jay Kruer" )
       ( mu4e-compose-signature .
              (concat
                 "\n"
                 "-jay"))
       ))
   ,(make-mu4e-context
     :name "iCloud"
     :match-func (lambda (msg) (when msg
       (string-prefix-p "/iCloud" (mu4e-message-field msg :maildir))))
     :vars '(
       (mu4e-sent-folder . "/iCloud/Sent")
       (mu4e-drafts-folder . "/iCloud/Drafts")
       (mu4e-trash-folder . "/iCloud/Deleted Messages")
       (mu4e-refile-folder . "/iCloud/Archive")
       (user-mail-address      . "jaykru@me.com"  )
                   ( user-full-name         . "Jay Kruer" )
                   ( mu4e-compose-signature .
                     (concat
                       "\n"
                       "-jay"))
       ))
   ))

(setq twittering-use-master-password t)

(setq multi-term-program "/run/current-system/sw/bin/bash")

(setq browse-url-browser-function 'browse-url-generic
      browse-url-generic-program "chromium-browser")

(display-battery-mode)

(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 )
>>>>>>> a27dfe93902eabb50d2edddcdd0c845fe0deb2df
