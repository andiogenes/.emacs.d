(package-initialize)

(setq custom-file "~/.emacs.d/custom.el")
(load custom-file)

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

;;; Font

(let ((font-default "Source Code Pro 14"))
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

;;; Minimize fringes

(fringe-mode '(1 . 1))

;;; Line highlighting in all buffers
(global-hl-line-mode)

;;; Feel

;; Fix idiosyncrasies
(setq make-backup-files nil)

;; Short Yes or No prompt
(defalias 'yes-or-no-p 'y-or-n-p)

;;; Shell
(setq-default explicit-shell-file-name "/bin/zsh")

;;; Dired
;; Show directories first
;; (setq dired-listing-switches "-al --group-directories-first")

;;; Sidebar file tree
(require 'neotree)

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
(defconst use-lsp nil)

(when use-lsp
  (require 'lsp-mode)
  (require 'dap-mode)

  (require 'flycheck)
  (global-flycheck-mode)

  (add-hook 'lsp-mode-hook #'lsp-lens-mode)

  (require 'lsp-ui))

;;;; Major modes

;;; Clojure
(require 'clojure-mode)

;;; Scala
(require 'scala-mode)
;; https://github.com/andiogenes/scala-ts-mode
(require 'scala-ts-mode)

(unless (treesit-language-available-p 'scala)
  (add-to-list
   'treesit-language-source-alist
   '(scala . ("https://github.com/tree-sitter/tree-sitter-scala")))
  (treesit-install-language-grammar 'scala))

(cl-assert (treesit-language-available-p 'scala))
(add-hook 'scala-mode-hook #'scala-ts-mode)

(when use-lsp
  ;; https://github.com/andiogenes/lsp-metals-self-delivery
  (require 'lsp-metals)
  (add-hook 'scala-mode-hook #'lsp))

;;; Magit
(require 'magit)

;;; Markdown
(require 'markdown-mode)
