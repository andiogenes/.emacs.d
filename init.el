(package-initialize)

(setq custom-file (expand-file-name "custom.el" user-emacs-directory))
(load custom-file)

(load (expand-file-name "sensitive.el" user-emacs-directory))

;;; Startup

(tool-bar-mode -1)
(scroll-bar-mode -1)
(setq inhibit-startup-screen t)

;;; Packages

(setq package-archives '(("gnu" . "http://elpa.gnu.org/packages/")
                         ("melpa" . "https://melpa.org/packages/")))

;;; Theme

(require 'modus-themes)
(load-theme 'modus-operandi t)

(defvar after-load-theme-hook nil)
;; https://www.reddit.com/r/emacs/comments/4v7tcj/comment/d5wyu1r/
(defadvice load-theme (after run-after-load-theme-hook activate)
    (run-hooks 'after-load-theme-hook))

;;; Font

(let ((font-default "IBM Plex Mono 16"))
  (set-face-attribute 'default nil :font font-default)
  (set-face-attribute 'fixed-pitch nil :font font-default))

;;; Parentheses

(show-paren-mode 1)
(setq show-paren-delay 0)

;;; Tabs

(setq-default tab-width 4)
(setq-default indent-tabs-mode nil)

;;; Line numbers

(global-display-line-numbers-mode)

;;; Frame

(add-to-list 'default-frame-alist '(fullscreen . maximized))

;; Remove annoying 1-pixel margin between native window and Emacs frame
(add-to-list 'default-frame-alist '(internal-border-width . 0))

;;; Minimize fringes

(fringe-mode '(1 . 1))

;;; Line highlighting in all buffers
(global-hl-line-mode)

;;; Feel

;; Fix idiosyncrasies
(setq make-backup-files nil)

;; Short Yes or No prompt
(defalias 'yes-or-no-p 'y-or-n-p)

;; Remap previous/next buffer
(global-set-key (kbd "M-[") 'previous-buffer)
(global-set-key (kbd "M-]") 'next-buffer)

;;; Shell
(setq-default explicit-shell-file-name "/bin/zsh")

;;; Dired
;; Show directories first
;; (setq dired-listing-switches "-al --group-directories-first")

;;; Sidebar file tree
(require 'treemacs)

(add-hook
 'treemacs-mode-hook
 (lambda () (display-line-numbers-mode -1)))

(global-set-key (kbd "M-g t") 'treemacs-select-window)

;;; Tab-bar-mode
(defface arx/tab-bar-separator
  `((t :weight extra-light
       :inherit (variable-pitch child-frame-border vertical-border default)))
  "Tab bar separator")

(setq tab-bar-separator (propertize "|" 'face 'arx/tab-bar-separator)
      tab-bar-auto-width nil)

;; Ace-window
(require 'ace-window)
(global-set-key (kbd "M-o") 'ace-window)

;; Avy
(require 'avy)
(global-set-key (kbd "C-x C-j") 'avy-goto-word-1)

;; Transpose frames
(require 'transpose-frame)

;;; Matching parentheses
(require 'elec-pair)
(electric-pair-mode)

;;; Buffer Menu
;; Display a list of existing buffers in current window
(global-set-key (kbd "C-x C-b") 'buffer-menu)

;; List buffers in other window using "C-x 4-" prefix
(global-set-key (kbd "C-x 4 C-x C-b") 'list-buffers)

;;; Rebind 'GOTO beginning/end of buffer' to "C-M-v"
(defun edge-of-buffer ()
  (interactive)
  (if (and current-prefix-arg (eq current-prefix-arg '-))
      (beginning-of-buffer) (end-of-buffer)))

(global-set-key (kbd "C-M-v") 'edge-of-buffer)

;;; Shell-here
(defun shell-here ()
  "Create new shell rooted at default-directory and open it in
   new window if there is no other shells associated with
   default-directory, open existing shell otherwise."
  (interactive)

  (let* ((buffer-dir (directory-file-name (expand-file-name default-directory)))
         (shell-buffer-name (concat "*shell*<" buffer-dir "/>")))
    (shell shell-buffer-name)))

;;; Completion
(require 'vertico)
(vertico-mode)

;; Like edge-of-buffer but for vertico minibuffer
(defun edge-of-vertico-buffer ()
  (interactive)
  (if (and current-prefix-arg (eq current-prefix-arg '-))
      (vertico-first) (vertico-last)))

(setq vertico-count 17)
(dolist
    (p '(("RET" . vertico-directory-enter)
         ("DEL" . vertico-directory-delete-char)
         ("M-DEL" . vertico-directory-delete-word)
         ("C-M-v" . edge-of-vertico-buffer)))
  (keymap-set vertico-map (car p) (cdr p)))

(require 'marginalia)
(marginalia-mode)

(require 'mini-frame)
(mini-frame-mode)
(custom-set-variables
 '(mini-frame-show-parameters
   '((top . 0.25)
     (width . 0.7)
     (left . 0.5))))

(require 'consult)
(global-set-key (kbd "M-g i") 'consult-imenu)

(require 'transient)
(transient-define-prefix consult-search-transient ()
  ["Consult search commands"
   ("r" "ripgrep" consult-ripgrep)
   ("f" "find" consult-find)])

(global-set-key (kbd "M-g s") 'consult-search-transient)

;; CoRFu
(require 'corfu)
(global-corfu-mode)
(corfu-popupinfo-mode)

;; Structural editing
(require 'treesit)

;; https://github.com/andiogenes/treesit-jump
(require 'treesit-jump)
(global-set-key (kbd "M-g j") 'treesit-jump-transient)

;; Language Server Protocol
(require 'eglot)

(defconst use-lsp nil)

(when use-lsp
  (require 'dap-mode)

  (require 'flycheck)
  (global-flycheck-mode))

;;;; Major modes

;;; Clojure
(require 'clojure-mode)
(require 'inf-clojure)

;;; Scala
(require 'scala-mode)
;; https://github.com/andiogenes/scala-ts-mode
;; (require 'scala-ts-mode)

;; (unless (treesit-language-available-p 'scala)
;;   (add-to-list
;;    'treesit-language-source-alist
;;    '(scala . ("https://github.com/tree-sitter/tree-sitter-scala")))
;;   (treesit-install-language-grammar 'scala))

;; (cl-assert (treesit-language-available-p 'scala))
;; (add-hook 'scala-mode-hook #'scala-ts-mode)

(when use-lsp
  ;; https://github.com/andiogenes/lsp-metals-self-delivery
  (require 'lsp-metals)
  (add-hook 'scala-mode-hook #'lsp))

;;; Magit
(require 'magit)

;;; Markdown
(require 'markdown-mode)

;;; Org-mode
(require 'org)
(require 'org-modern)

(add-hook 'org-mode-hook #'org-modern-mode)

;;; Scheme
(require 'geiser)
(require 'geiser-kawa)

;;; LUA

(require 'lua-mode)

;;; Custom dashboard Mode
(load (expand-file-name "dashboard.el" user-emacs-directory))
(setq arx/dashboard-unseen-university-dir sensitive/unseen-university-dir)
(arx/dashboard-setup-hooks)

;;; Twitch chatting with ERC
(load (expand-file-name "twitch.el" user-emacs-directory))
;; TODO: use GnuPG
(setq arx/twitch-client-id sensitive/twitch-client-id
      arx/twitch-nick sensitive/twitch-nick
      arx/twitch-access-token sensitive/twitch-access-token)

(add-hook
 'erc-mode-hook
 (lambda ()
   (load-theme 'modus-vivendi-tinted t)
   (display-line-numbers-mode -1)))

;; Switch to buffer of the joined channel
(add-hook
 'erc-join-hook
 (lambda () (switch-to-buffer (current-buffer))))

;; Automatically layout Emacs current frame and browser using AppleScript
(defun twitch-layout-os-windows ()
  "Automatically layout Emacs current frame and browser."
  (interactive)
  (when (yes-or-no-p (format "Reminder: windows will be arranged properly only if there is only one active instance of Emacs.app and %s.app and they're in the same workspace. Continue?"
                             sensitive/twitch-browser-app))
    ;; Set Emacs frame bounds
    (pcase-let ((`(,x ,y ,w ,h) sensitive/twitch-emacs-bounds))
      (set-frame-position (selected-frame) x y)
      (set-frame-size nil w h t))
    ;; Set Browser window bounds
    (pcase-let ((`(,x ,y ,w ,h) sensitive/twitch-browser-bounds))
      (let* ((script-file (expand-file-name "./non-el/resize-other-app.applescript" user-emacs-directory))
             (osascript-command
              (concat "osascript "
                      script-file
                      " "
                      sensitive/twitch-browser-app
                      " "
                      (mapconcat #'number-to-string sensitive/twitch-browser-bounds " "))))
        (call-process-shell-command osascript-command nil 0 nil)))))

;; Show code listings in browser

(load (expand-file-name "listing.el" user-emacs-directory))
(setq arx/highlight-js-path
      (expand-file-name
       "./non-el/third-party/highlight-js/highlight.min.js" user-emacs-directory)

      arx/highlight-js-css-path
      (expand-file-name "./non-el/third-party/highlight-js/styles/idea.css" user-emacs-directory))
