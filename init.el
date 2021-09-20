(package-initialize)

(setq custom-file "~/.emacs.d/custom.el")
(load custom-file)

(require 'org)
(org-babel-load-file (expand-file-name "config.org" user-emacs-directory))
