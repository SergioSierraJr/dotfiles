; initializing elpaca
(defvar elpaca-installer-version 0.11)
(defvar elpaca-directory (expand-file-name "elpaca/" user-emacs-directory))
(defvar elpaca-builds-directory (expand-file-name "builds/" elpaca-directory))
(defvar elpaca-repos-directory (expand-file-name "repos/" elpaca-directory))
(defvar elpaca-order '(elpaca :repo "https://github.com/progfolio/elpaca.git"
                              :ref nil :depth 1 :inherit ignore
                              :files (:defaults "elpaca-test.el" (:exclude "extensions"))
                              :build (:not elpaca--activate-package)))
(let* ((repo  (expand-file-name "elpaca/" elpaca-repos-directory))
       (build (expand-file-name "elpaca/" elpaca-builds-directory))
       (order (cdr elpaca-order))
       (default-directory repo))
  (add-to-list 'load-path (if (file-exists-p build) build repo))
  (unless (file-exists-p repo)
    (make-directory repo t)
    (when (<= emacs-major-version 28) (require 'subr-x))
    (condition-case-unless-debug err
        (if-let* ((buffer (pop-to-buffer-same-window "*elpaca-bootstrap*"))
                  ((zerop (apply #'call-process `("git" nil ,buffer t "clone"
                                                  ,@(when-let* ((depth (plist-get order :depth)))
                                                      (list (format "--depth=%d" depth) "--no-single-branch"))
                                                  ,(plist-get order :repo) ,repo))))
                  ((zerop (call-process "git" nil buffer t "checkout"
                                        (or (plist-get order :ref) "--"))))
                  (emacs (concat invocation-directory invocation-name))
                  ((zerop (call-process emacs nil buffer nil "-Q" "-L" "." "--batch"
                                        "--eval" "(byte-recompile-directory \".\" 0 'force)")))
                  ((require 'elpaca))
                  ((elpaca-generate-autoloads "elpaca" repo)))
            (progn (message "%s" (buffer-string)) (kill-buffer buffer))
          (error "%s" (with-current-buffer buffer (buffer-string))))
      ((error) (warn "%s" err) (delete-directory repo 'recursive))))
  (unless (require 'elpaca-autoloads nil t)
    (require 'elpaca)
    (elpaca-generate-autoloads "elpaca" repo)
    (let ((load-source-file-function nil)) (load "./elpaca-autoloads"))))
(add-hook 'after-init-hook #'elpaca-process-queues)
(elpaca `(,@elpaca-order))
(setq package-enable-at-startup nil)

; emacs configuration
(use-package emacs
    :init
    ; for text editing:
    (setq show-paren-delay 0)
    (show-paren-mode 1)
    (electric-pair-mode 1)
    (cua-mode)
    (setq-default cursor-type 'bar) 

    ; for the UI:
    (menu-bar-mode -1)
    (scroll-bar-mode -1)
    (tool-bar-mode -1)
    (global-display-line-numbers-mode)

    ; frame alists
    (add-to-list 'default-frame-alist '(fullscreen . maximized))
    (add-to-list 'default-frame-alist '(font . "CaskaydiaMono Nerd Font-12"))
    (add-to-list 'default-frame-alist '(title . "EMACS"))
    (add-to-list 'default-frame-alist '(undecorated . t))

					; lastly, focus on the frame
    (select-frame-set-input-focus (selected-frame))
)

;;; installing and configuring packages

; firstly, the obligatory elpaca-use-package-mode
(elpaca elpaca-use-package
    (elpaca-use-package-mode))

; my theme of choice(Gruvbox Dark Hard)
(use-package gruvbox-theme
    :ensure t
    :config
    (load-theme 'gruvbox-dark-hard t))

; evil mode, because of the superior keybinds
(use-package evil
    :ensure t
    :config
    (evil-mode 1))

; tree sitter for superior syntax highlighting
(use-package tree-sitter
    :ensure t tree-sitter-langs
    :config
    (global-tree-sitter-mode)
    (add-hook 'tree-sitter-after-on-hook #'tree-sitter-hl-mode))

					; eglot + booster and company mode for lsp and completion
(use-package flymake
  :ensure t)

(use-package eglot
  :ensure t
  :after flymake
  :hook ((prog-mode . eglot-ensure)))

(use-package eglot-booster
  :ensure (:host github :repo "jdtsmith/eglot-booster")
  :after eglot
  :config
  (eglot-booster-mode))

(use-package company
  :ensure t
  :after eglot-booster
  :hook ((prog-mode . company-mode))
  :config
  (setq company-minimum-prefix-length 1))

					; programming modes
(use-package rust-mode
  :ensure t)
