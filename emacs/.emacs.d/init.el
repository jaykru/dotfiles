
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

;; quiet, you.
(setq ring-bell-function 'ignore)

;; ivy
(ivy-mode 1)
(setq ivy-use-virtual-buffers t) (setq ivy-count-format "(%d/%d) ")
(global-set-key (kbd "C-s") 'swiper) (global-set-key (kbd "M-x") 'counsel-M-x) (global-set-key (kbd "C-x C-f") 'counsel-find-file) (global-set-key (kbd "<f1> f") 'counsel-describe-function) (global-set-key (kbd "<f1> v") 'counsel-describe-variable) (global-set-key (kbd "<f1> l") 'counsel-find-library) (global-set-key (kbd "<f2> i") 'counsel-info-lookup-symbol) (global-set-key (kbd "<f2> u") 'counsel-unicode-char)

;; fuzzy matching
;(setq ivy-re-builders-alist
;      '((t . ivy--regex-fuzzy)))

(setq default-frame-alist
      '((font . "Inconsolata")
        (vertical-scroll-bars . nil)
        (horizontal-scroll-bars . nil)
        (tool-bar-lines . 0)
        (menu-bar-lines . 0)
        (left-fringe . 0)
        (right-fringe . 0)))

(set-face-attribute 'default nil :height 110)

;; mark theme as safe
(custom-set-variables
  '(org-agenda-files (quote ("~/life.org")))
  '(custom-safe-themes
    (quote
     ("d6922c974e8a78378eacb01414183ce32bc8dbf2de78aabcc6ad8172547cb074" "2cf7f9d1d8e4d735ba53facdc3c6f3271086b6906c4165b12e4fd8e3865469a6" default))))
;; load it
(load-theme 'plan9)

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

;(exec-path-from-shell-initialize)
(setq epa-pinentry-mode 'loopback)
(pinentry-start)
(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(TeX-view-program-list (quote (("Zathura" "zathura %o"))))
 '(TeX-view-program-selection
   (quote
    (((output-dvi has-no-display-manager)
      "dvi2tty")
     ((output-dvi style-pstricks)
      "dvips and gv")
     (output-dvi "xdvi")
     (output-pdf "Zathura")
     (output-html "xdg-open"))))
 '(custom-safe-themes
   (quote
    ("ef1e992ef341e86397b39ee6b41c1368e1b33d45b0848feac6a8e8d5753daa67" "4f2ede02b3324c2f788f4e0bad77f7ebc1874eff7971d2a2c9b9724a50fb3f65" "d6922c974e8a78378eacb01414183ce32bc8dbf2de78aabcc6ad8172547cb074" "2cf7f9d1d8e4d735ba53facdc3c6f3271086b6906c4165b12e4fd8e3865469a6" default)))
 '(org-agenda-files (quote ("~/life.org")))
 '(package-selected-packages
   (quote
    (rust-mode multi-term hledger-mode org-alert visual-regexp znc wolfram w3m w3 undo-tree typing-game twittering-mode turing-machine threes tao-theme solidity-mode sml-mode smex slime scratches rainbow-mode rainbow-delimiters plan9-theme paredit org-bullets nixos-options nix-sandbox nix-mode moe-theme mingus memoize math-symbol-lists magit-annex latex-pretty-symbols japanlaw ix heroku-theme haskell-mode hacker-typer golden-ratio go-guru go-eldoc go-complete go-autocomplete go gnugo flx fireplace find-file-in-project figlet expand-region deft cyberpunk-theme counsel ciel chess buffer-sets buffer-move basic-mode autotetris-mode auctex 0xc)))
 '(preview-TeX-style-dir "/home/j/.emacs.d/elpa/auctex-12.1.0/latex" t))

(add-hook 'prog-mode-hook
          (lambda ()
            (progn
              (rainbow-delimiters-mode t))))

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
(setq alert-default-style 'notifications)
(org-alert-enable)

(setq org-format-latex-options (plist-put org-format-latex-options :scale 2.0))

;(setq pdf-latex-command "lualatex") ; ab fontes :'(

(load "~/.emacs.d/lisp/PG/generic/proof-site")

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
