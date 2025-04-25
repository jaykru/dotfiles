;;; $DOOMDIR/config.el -*- lexical-binding: t; -*-
;; Place your private configuration here! Remember, you do not need to run 'doom
;; sync' after modifying this file!


;; Some functionality uses this to identify you, e.g. GPG configuration, email
;; clients, file templates and snippets. It is optional.
(setq user-full-name "Jay Kruer"
      user-mail-address "j@dank.systems")

;; Doom exposes five (optional) variables for controlling fonts in Doom:
;;
;; - `doom-font' -- the primary font to use
;; - `doom-variable-pitch-font' -- a non-monospace font (where applicable)
;; - `doom-big-font' -- used for `doom-big-font-mode'; use this for
;;   presentations or streaming.
;; - `doom-unicode-font' -- for unicode glyphs
;; - `doom-serif-font' -- for the `fixed-pitch-serif' face
(setq doom-font "Berkeley Mono")
;;
;; See 'C-h v doom-font' for documentation and more examples of what they
;; accept. For example:
;;
;;(setq doom-font (font-spec :family "Fira Code" :size 12 :weight 'semi-light)
;;      doom-variable-pitch-font (font-spec :family "Fira Sans" :size 13))
;;
;; If you or Emacs can't find your font, use 'M-x describe-font' to look them
;; up, `M-x eval-region' to execute elisp code, and 'M-x doom/reload-font' to
;; refresh your font settings. If Emacs still can't find your font, it likely
;; wasn't installed correctly. Font issues are rarely Doom issues!

;; There are two ways to load a theme. Both assume the theme is installed and
;; available. You can either set `doom-theme' or manually load a theme with the
;; `load-theme' function. This is the default:
(setq doom-theme 'doom-one)

;; This determines the style of line numbers in effect. If set to `nil', line
;; numbers are disabled. For relative line numbers, set this to `relative'.
(setq display-line-numbers-type t)

;; If you use `org' and don't want your org files in the default location below,
;; change `org-directory'. It must be set before org loads!
(setq org-directory "~/org/")


;; Whenever you reconfigure a package, make sure to wrap your config in an
;; `after!' block, otherwise Doom's defaults may override your settings. E.g.
;;
;;   (after! PACKAGE
;;     (setq x y))
;;
;; The exceptions to this rule:
;;
;;   - Setting file/directory variables (like `org-directory')
;;   - Setting variables which explicitly tell you to set them before their
;;     package is loaded (see 'C-h v VARIABLE' to look up their documentation).
;;   - Setting doom variables (which start with 'doom-' or '+').
;;
;; Here are some additional functions/macros that will help you configure Doom.
;;
;; - `load!' for loading external *.el files relative to this one
;; - `use-package!' for configuring packages
;; - `after!' for running code after a package has loaded
;; - `add-load-path!' for adding directories to the `load-path', relative to
;;   this file. Emacs searches the `load-path' when you load packages with
;;   `require' or `use-package'.
;; - `map!' for binding new keys
;;
;; To get information about any of these functions/macros, move the cursor over
;; the highlighted symbol at press 'K' (non-evil users must press 'C-c c k').
;; This will open documentation for it, including demos of how they are used.
;; Alternatively, use `C-h o' to look up a symbol (functions, variables, faces,
;; etc).
;;
;; You can also try 'gd' (or 'C-c c d') to jump to their definition and see how
;; they are implemented.

(global-set-key (kbd "C-x b") 'switch-to-buffer)
(require 'agda-input)
(set-input-method "Agda")
(add-hook 'agda2-mode-hook
          (local-set-key (kbd "C-c C-g") 'agda2-next-goal) )
(set-variable 'notmuch-search-oldest-first nil)
;; (use-package! chatgpt
;;   (chatgpt :type git :host github :repo "emacs-openai/chatgpt"))
(setq doom-unreal-buffer-functions '(minibufferp))
(set-variable '+popup-default-parameters
              (assq-delete-all 'no-other-window +popup-default-parameters))
(remove-hook '+popup-buffer-mode-hook #'+popup-set-modeline-on-enable-h) ; show modeline for popup windows.

(defvar gemini-api-key-file (expand-file-name "~/.gemini-api-key"))
(defvar deepseek-api-key-file (expand-file-name "~/.deepseek-api-key"))

(defun read-api-key (api-key-file)
  (with-temp-buffer
    (insert-file-contents api-key-file)
    (goto-char (point-min))
    (while (re-search-forward "[\n\t ]+$" nil t)
      (replace-match ""))
    (buffer-string)))

(gptel-make-deepseek "DeepSeek"
  :stream t
  :key (read-api-key deepseek-api-key-file))

(defconst my-gemini-models
  '(
    (gemini-2.5-pro-preview-03-25
     :description "Google goes crazy"
     :capabilities (tool-use json media)
     :mime-types ("image/png" "image/jpeg" "image/webp" "image/heic" "image/heif"
                  "application/pdf" "text/plain" "text/csv" "text/html")
     :context-window 1000)
    (gemini-2.0-flash
     :description "I am speed"
     :capabilities (tool-use json media)
     :mime-types ("image/png" "image/jpeg" "image/webp" "image/heic" "image/heif"
                  "application/pdf" "text/plain" "text/csv" "text/html")
     :context-window 1000
     )))

(gptel-make-gemini
    "Gemini"
  :key (read-api-key gemini-api-key-file)
  :stream t
  :models my-gemini-models)

(setq gptel-model 'deepseek-chat)
;; asks gptel a question about the current buffer; response will appear in a separate
;; buffer
(defvar gptel-ask--history nil)
(defun gptel-ask ()
  (interactive)
  (let* ((context (if (region-active-p)
                      (buffer-substring (region-beginning) (region-end))
                    (buffer-string)))
         (prompt (read-string "Ask gptel: " nil gptel-ask--history nil))
        (prompt-with-context (concat "Here's the context: "
                                     context
                                     "\n"
                                     prompt)))
    (gptel-request
        prompt-with-context
      ;; :buffer resp-buffer
      :system "Be concise, but not at the expanse of answering
      the query completely. When responding with code, use
      markdown to format your answer. If the user hasn't asked a
      question, just explain the lines of code or evaluate it."
      :callback (lambda (response info)
                  (if (not response)
                      (message "gptel-lookup failed with message: %s" (plist-get info :status))
                    (with-current-buffer (get-buffer-create "*gptel answer*")
                      (let ((inhibit-read-only t))
                        (markdown-mode)
                        (erase-buffer)
                        (insert response))
                      (display-buffer (current-buffer)
                                      `((display-buffer-in-side-window)
                                        (side . bottom)
                                        (window-height . ,#'fit-window-to-buffer)))))))))

(global-set-key (kbd "C-c g c") 'gptel)
(global-set-key (kbd "C-c g r") 'gptel-rewrite)
(global-set-key (kbd "C-c g s") 'gptel-send)
(global-set-key (kbd "C-c k") 'gptel-menu)
(global-set-key (kbd "C-c q") 'gptel-ask)

;;  in vterm-mode, bind C-x C-j to 'vterm-copy-mode
(add-hook 'vterm-mode-hook
          (lambda ()
            (define-key vterm-mode-map (kbd "C-x j") 'vterm-copy-mode)))

;; also need a hook for vterm-copy-mode to invoke vterm-copy-mode-done
(add-hook 'vterm-copy-mode-hook
          (lambda ()
            (define-key vterm-copy-mode-map (kbd "C-x j") 'vterm-copy-mode-done)))

;;; magit customizations
;; (transient-append-suffix 'magit-submodule "u" ; add it after the "update submodule one"
;;   '("a" "Update/init all submodules recursively" (lambda ()
;;                        (interactive)
;;                        (magit-run-git "submodule" "update" "--init" "--recursive"))))
(require 'cider-storm)
(add-to-list 'cider-jack-in-nrepl-middlewares "flow-storm.nrepl.middleware/wrap-flow-storm")

;; (defmacro with-cur-buffer (body)
;;   `(progn
;;      (gptel-add)
;;      ,body
;;      (quiet!! (gptel-add))))

;; (defun cursory-diff-gen ()
;;   (with-cur-buffer
;;    (gptel-request "Based on the current position in this text and the buffer
;; context, propose an edit as a diff for the current file."))
;;   )

(require 'meow)
(meow-global-mode 1)
(require 'transient)
(transient-define-prefix meow-goto-menu ()
  "Goto"
  ["goto"
   ("g" "Beginning of buffer" beginning-of-buffer)
   ("e" "End of buffer" end-of-buffer)
   ("h" "Beginning of line" beginning-of-line)
   ("l" "End of line" end-of-line)
   ("b" "Buffer" consult-buffer)
   ("k" "Page up" meow-page-up)
   ("j" "Page down" meow-page-down)
   ("d" "Definition" xref-find-definitions)
   ("." "Jump forward" xref-go-forward)
   (","  "Jump backward" xref-go-back)
   ("SPC" "jump" avy-goto-char-timer)])

(transient-define-prefix meow-match-menu ()
  "Match"
  ["match"
   ("i" "select inside object" meow-inner-of-thing)
   ("a" "select around object" meow-bounds-of-thing)])

(transient-define-prefix meow-window-menu ()
  "Window"
  ["Window"
   ("w" "go to next window" other-window)
   ("'" "vertical split" split-window-right)
   ("-" "horizontal split" split-window-below)
   ("q" "kill current window" delete-window)
   ("m" "kill all windows but current" delete-other-windows)

   ("h" "go left" windmove-left)
   ("j" "go down" windmove-down)
   ("k" "go up" windmove-up)
   ("l" "go right" windmove-right)

   ("H" "go left" windmove-swap-states-left)
   ("J" "go down" windmove-swap-states-down)
   ("K" "go up" windmove-swap-states-up)
   ("L" "go right" windmove-swap-states-right)])

(global-unset-key (kbd "C-c w"))
(global-set-key (kbd "C-c w") 'meow-window-menu)

(defun meow-delete-or-kill ()
  (interactive)
  (if (region-active-p)
    (meow-kill)
    (meow-delete)))

(meow-define-keys
    'normal
  '("d" . meow-delete-or-kill)
  '("s" . isearch-forward)
  '("g" . meow-goto-menu)
  '("m" . meow-match-menu))

(setq symex--user-evil-keyspec
      '(("j" . symex-go-up)
        ("k" . symex-go-down)
        ("C-j" . symex-climb-branch)
        ("C-k" . symex-descend-branch)
        ("M-j" . symex-goto-highest)
        ("M-k" . symex-goto-lowest)))
; (symex-initialize)
(global-set-key (kbd "C-c ;") 'symex-mode-interface)

(set-variable 'avy-all-windows t)
