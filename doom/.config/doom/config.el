;;; $DOOMDIR/config.el -*- lexical-binding: t; -*-
(setq user-full-name "Jay Kruer"
      user-mail-address "j@dank.systems")

(setq doom-font "Berkeley Mono")
(setq doom-theme 'doom-one)

;; This determines the style of line numbers in effect. If set to `nil', line
;; numbers are disabled. For relative line numbers, set this to `relative'.
(setq display-line-numbers-type t)

;; If you use `org' and don't want your org files in the default location below,
;; change `org-directory'. It must be set before org loads!
(setq org-directory "~/org/")

(global-set-key (kbd "C-x b") 'switch-to-buffer)
(set-variable 'notmuch-search-oldest-first nil)

(setq doom-unreal-buffer-functions '(minibufferp))
(set-variable '+popup-default-parameters
              (assq-delete-all 'no-other-window +popup-default-parameters))
(remove-hook '+popup-buffer-mode-hook #'+popup-set-modeline-on-enable-h) ; show modeline for popup windows.

;;  in vterm-mode, bind C-x C-j to 'vterm-copy-mode
(add-hook 'vterm-mode-hook
          (lambda ()
            (define-key vterm-mode-map (kbd "C-x j") 'vterm-copy-mode)))

;; also need a hook for vterm-copy-mode to invoke vterm-copy-mode-done
(add-hook 'vterm-copy-mode-hook
          (lambda ()
            (define-key vterm-copy-mode-map (kbd "C-x j") 'vterm-copy-mode-done)))

(setq lsp-clients-clangd-args '("-j=3"
                                "--background-index"
                                "--clang-tidy"
                                "--completion-style=detailed"
                                "--header-insertion=never"
                                "--header-insertion-decorators=0"))
(after! lsp-clangd (set-lsp-priority! 'clangd 2))

(add-load-path! ".")
(load "gptel-config.el")
(load "meow-config.el")
