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
(set-variable 'notmuch-search-oldest-first nil)
;; (use-package! chatgpt
;;   (chatgpt :type git :host github :repo "emacs-openai/chatgpt"))
(setq doom-unreal-buffer-functions '(minibufferp))
(set-variable '+popup-default-parameters
              (assq-delete-all 'no-other-window +popup-default-parameters))
(remove-hook '+popup-buffer-mode-hook #'+popup-set-modeline-on-enable-h) ; show modeline for popup windows.

;; gptel configuration
(require 'gptel)

(defvar gemini-api-key-file (expand-file-name "~/.gemini-api-key"))
(defvar deepseek-api-key-file (expand-file-name "~/.deepseek-api-key"))
(defvar brave-search-api-key-file (expand-file-name "~/.brave-search-api-key"))

(defun read-api-key (api-key-file)
  "Read API key from API-KEY-FILE, removing trailing whitespace."
  (when (file-exists-p api-key-file)
    (with-temp-buffer
      (insert-file-contents api-key-file)
      (goto-char (point-min))
      (while (re-search-forward "[\n\t ]+$" nil t)
        (replace-match ""))
      (buffer-string))))

;; Conditionally configure DeepSeek
(if (file-exists-p deepseek-api-key-file)
    (progn
      (gptel-make-deepseek "DeepSeek"
        :stream t
        :key (read-api-key deepseek-api-key-file))
      ;; Set default model only if DeepSeek is configured)
  (message "DeepSeek API key file not found: %s. DeepSeek provider not configured." deepseek-api-key-file)))
;; Conditionally configure Gemini
(if (file-exists-p gemini-api-key-file)
    (progn
      (gptel-make-gemini
          "Gemini"
        :key (read-api-key gemini-api-key-file)
        :stream t)
      (setq gptel-model 'gemini))
  (message "Gemini API key file not found: %s. Gemini provider not configured." gemini-api-key-file))

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
(global-set-key (kbd "C-c g m") 'gptel-menu)
(global-set-key (kbd "C-c g a") 'gptel-ask)

;; more gptel stuff
;; Enable tool use
(setq gptel-use-tools t)

(defun add-tools (&rest tools)
  (mapcar (lambda (tool)
            (when tool
              (add-to-list 'gptel-tools
                           tool))) tools))

(add-tools
 ; read_file
 (gptel-make-tool
  :function (lambda (filepath)
              (with-temp-buffer
                (insert-file-contents (expand-file-name filepath))
                (buffer-string)))
  :name "read_file"
  :description "Read and display the contents of a file"
  :args (list '(:name "filepath"
                :type string
                :description "Path to the file to read. Supports relative paths and ~."))
  :category "filesystem")

                                        ; list_directory
 (gptel-make-tool
  :function (lambda (directory)
              (mapconcat #'identity
                         (directory-files directory)
                         "\n"))
  :name "list_directory"
  :description "List the contents of a given directory"
  :args (list '(:name "directory"
                :type string
                :description "The path to the directory to list"))
  :category "filesystem")

                                        ; mkdir
 (gptel-make-tool
  :function (lambda (parent name)
              (condition-case nil
                  (progn
                    (make-directory (expand-file-name name parent) t)
                    (format "Directory %s created/verified in %s" name parent))
                (error (format "Error creating directory %s in %s" name parent))))
  :name "make_directory"
  :description "Create a new directory with the given name in the specified parent directory"
  :args (list '(:name "parent"
                :type string
                :description "The parent directory where the new directory should be created, e.g. /tmp")
              '(:name "name"
                :type string
                :description "The name of the new directory to create, e.g. testdir"))
  :category "filesystem")

                                        ; create_file
 (gptel-make-tool
  :function (lambda (path filename content)
              (let ((full-path (expand-file-name filename path)))
                (with-temp-buffer
                  (insert content)
                  (write-file full-path))
                (format "Created file %s in %s" filename path)))
  :name "create_file"
  :description "Create a new file with the specified content"
  :args (list '(:name "path"
                :type string
                :description "The directory where to create the file")
              '(:name "filename"
                :type string
                :description "The name of the file to create")
              '(:name "content"
                :type string
                :description "The content to write to the file"))
  :category "filesystem")

                                        ; edit_file


 (gptel-make-tool
  :function (lambda (file-path file-edits)
              "In FILE-PATH, apply FILE-EDITS with pattern matching and replacing."
              (if (and file-path (not (string= file-path "")) file-edits)
                  (with-current-buffer (get-buffer-create "*edit-file*")
                    (insert-file-contents (expand-file-name file-path))
                    (let ((inhibit-read-only t)
                          (case-fold-search nil)
                          (file-name (expand-file-name file-path))
                          (edit-success nil))
                      ;; apply changes
                      (dolist (file-edit (seq-into file-edits 'list))
                        (when-let ((line-number (plist-get file-edit :line_number))
                                   (old-string (plist-get file-edit :old_string))
                                   (new-string (plist-get file-edit :new_string))
                                   (is-valid-old-string (not (string= old-string ""))))
                          (goto-char (point-min))
                          (forward-line (1- line-number))
                          (when (search-forward old-string nil t)
                            (replace-match new-string t t)
                            (setq edit-success t))))
                      ;; return result to gptel
                      (if edit-success
                          (progn
                            ;; show diffs
                            (ediff-buffers (find-file-noselect file-name) (current-buffer))
                            (format "Successfully edited %s" file-name))
                        (format "Failed to edited %s" file-name))))
                (format "Failed to edited %s" file-path)))
  :name "edit_file"
  :description "Edit file with a list of edits, each edit contains a line-number,
a old-string and a new-string, new-string will replace the old-string at the specified line."
  :args (list '(:name "file-path"
                :type string
                :description "The full path of the file to edit")
              '(:name "file-edits"
                :type array
                :items (:type object
                        :properties
                        (:line_number
                         (:type integer :description "The line number of the file where edit starts.")
                         :old_string
                         (:type string :description "The old-string to be replaced.")
                         :new_string
                         (:type string :description "The new-string to replace old-string.")))
                :description "The list of edits to apply on the file"))
  :category "filesystem")

                                        ; run_script
 (gptel-make-tool
  :function (lambda (script_program script_file script_args)
              (with-temp-message "Executing command ..."
                (shell-command-to-string
                 (concat script_program " "
                         (expand-file-name script_file) " "
                         script_args))))
  :name "run_script"
  :description "Run script"
  :args (list
         '(:name "script_program"
           :type string
           :description "Program to run the the script.")
         '(:name "script_file"
           :type string
           :description "Path to the script to run. Supports relative paths and ~.")
         '(:name "script_args"
           :type string
           :description "Args for script to run."))
  :category "filesystem")

                                        ; run_command
 (gptel-make-tool
  :function (lambda (command)
              (with-temp-message (format "Running command: %s" command)
                (shell-command-to-string command)))
  :name "run_command"
  :description "Run a command."
  :args (list
         '(:name "command"
           :type "string"
           :description "Command to run."))
  :category "command")

                                        ; run_async_command


 (gptel-make-tool
  :function (lambda (callback command)
   "Run COMMAND asynchronously and pass output to CALLBACK."
   (condition-case error
       (let ((buffer (generate-new-buffer " *async output*")))
         (with-temp-message (format "Running async command: %s" command)
           (async-shell-command command buffer nil))
         (let ((proc (get-buffer-process buffer)))
           (when proc
             (set-process-sentinel
              proc
              (lambda (process _event)
                (unless (process-live-p process)
                  (with-current-buffer (process-buffer process)
                    (let ((output (buffer-substring-no-properties (point-min) (point-max))))
                      (kill-buffer (current-buffer))
                      (funcall callback output)))))))))
     (t
      ;; Handle any kind of error
      (funcall callback (format "An error occurred: %s" error)))))
  :name "run_async_command"
  :description "Run an async command."
  :args (list
         '(:name "command"
           :type "string"
           :description "Command to run."))
  :category "command"
  :async t
  :include t)

                                        ; echo_message
 (gptel-make-tool
  :function (lambda (text)
              (message "%s" text)
              (format "Message sent: %s" text))
  :name "echo_message"
  :description "Send a message to the *Messages* buffer"
  :args (list '(:name "text"
                :type string
                :description "The text to send to the messages buffer"))
  :category "emacs")

                                        ; read_url
 (gptel-make-tool
  :function (lambda (url)
              (with-current-buffer (url-retrieve-synchronously url)
                (goto-char (point-min))
                (forward-paragraph)
                (let ((dom (libxml-parse-html-region (point) (point-max))))
                  (run-at-time 0 nil #'kill-buffer (current-buffer))
                  (with-temp-buffer
                    (shr-insert-document dom)
                    (buffer-substring-no-properties (point-min) (point-max))))))
  :name "read_url"
  :description "Fetch and read the contents of a URL"
  :args (list '(:name "url"
                :type string
                :description "The URL to read"))
  :category "web")

                                        ; read_buffer
 (gptel-make-tool
  :function (lambda (buffer)
              (unless (buffer-live-p (get-buffer buffer))
                (error "Error: buffer %s is not live." buffer))
              (with-current-buffer buffer
                (buffer-substring-no-properties (point-min) (point-max))))
  :name "read_buffer"
  :description "Return the contents of an Emacs buffer"
  :args (list '(:name "buffer"
                :type string
                :description "The name of the buffer whose contents are to be retrieved"))
  :category "emacs")

; get_buffer_path
(gptel-make-tool
  :function (lambda (buffer)
              (unless (buffer-live-p (get-buffer buffer))
                (error "Error: buffer %s is not live." buffer))
              (with-current-buffer buffer
                (buffer-file-name)))
  :name "get_buffer_path"
  :description "Return the full fs path of an Emacs buffer"
  :args (list '(:name "buffer"
                :type string
                :description "The name of the buffer whose contents are to be retrieved"))
  :category "emacs")
                                        ; append_to_buffer
 (gptel-make-tool
  :function (lambda (buffer text)
              (with-current-buffer (get-buffer-create buffer)
                (save-excursion
                  (goto-char (point-max))
                  (insert text)))
              (format "Appended text to buffer %s" buffer))
  :name "append_to_buffer"
  :description "Append text to an Emacs buffer. If the buffer does not exist, it will be created."
  :args (list '(:name "buffer"
                :type string
                :description "The name of the buffer to append text to.")
              '(:name "text"
                :type string
                :description "The text to append to the buffer."))
  :category "emacs")

; list_buffers
(gptel-make-tool
 :name "list_buffers"
 :function (lambda ()
             (mapconcat #'buffer-name (buffer-list) ", "))
 :description "List current Emacs buffers"
 :args '()
 :category "emacs")

; apply text substitution in buffer
(gptel-make-tool
 :function (lambda (buffer pattern replacement-pattern)
              (with-current-buffer (get-buffer-create buffer)
               (goto-char 0)
               (save-excursion
                 (while (re-search-forward pattern nil t)
                   (replace-match replacement-pattern nil nil)))))
 :name "subst_in_buffer"
 :args (list '(:name "buffer"
                :type string
                :description "The name of the buffer to append text to.")
              '(:name "pattern"
                :type string
                :description "The Emacs regexp pattern to match.")
              '(:name "replacement-pattern"
                :type string
                :description "The replacement pattern by which to replace matches."))
 :description "Applies a substitution to a buffer. The substitution is applied over the
entire buffer beginning with the first character. The pattern is
specified in Emacs regular expression syntax. The replacement pattern
need not be constant; it can refer to all or part of what is matched by
the pattern: '\&' refers to the entire match; '\d' where d is a number
starting from 1, stands for whatever matched the dth parenthesized
grouping in the pattern; '\#' refers to the count of replacements
already made by this command. Here is a brief summary of the syntax:
Emacs regular expressions use a combination of ordinary characters and
special constructs. Ordinary characters match themselves exactly, while
special characters ($^.*+?[\) have specific meanings. The primary
special characters and their functions are:

. matches any single character except newline * is a postfix operator
that matches the preceding expression zero or more times (greedy) +
matches the preceding expression one or more times (greedy) ? matches
the preceding expression zero or one time (greedy) *?, +?, ?? are
non-greedy variants of the above operators [...] creates a bracket
expression matching any one of the enclosed characters [^...] creates a
complemented bracket expression matching any character except those
enclosed ^ matches the empty string at the beginning of a line $ matches
the empty string at the end of a line \ quotes special characters and
introduces additional special constructs

Bracket expressions can include individual characters, character ranges
denoted by - (like [a-z]), and character classes enclosed in [: :] (like
[:alnum:]). Special rules apply when including ], -, or ^ within bracket
expressions. When in case-insensitive search, ranges should use
consistent case. The manual notes that regular expressions can be
concatenated, and that operators apply to the smallest possible
preceding expression."
 :category "emacs")

; brave search
(let ((brave-search-api-key (read-api-key brave-search-api-key-file))
      (do-brave-search (lambda (query)
                         "Perform a web search using the Brave Search API with the given QUERY."
                         (let ((url-request-method "GET")
                               (url-request-extra-headers `("X-Subscription-Token" . ,brave-search-api-key))
                               (url (format "https://api.search.brave.com/res/v1/web/search?q=%s" (url-encode-url query))))
                           (with-current-buffer (url-retrieve-synchronously url)
                             (goto-char (point-min))
                             (when (re-search-forward "^$" nil 'move)
                               (let ((json-object-type 'hash-table)) ; Use hash-table for JSON parsing
                                 (json-parse-string (buffer-substring-no-properties (point) (point-max))))))))))
  (when brave-search-api-key
    (gptel-make-tool
     :function
     do-brave-search
     :name "brave_search"
     :description "Perform a web search using the Brave Search API"
     :args (list '(:name "query"
                   :type string
                   :description "The search query string"))
     :category "web")))

)

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

; FIXME: remove when meow config is ready
(meow-global-mode -1)

(set-variable 'avy-all-windows t)
