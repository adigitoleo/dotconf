# dotconf

Dotfiles, configs and scripts for the Linux habitat.
I manage these files with the Git-based [yadm](https://yadm.io/) tool.

I use both Void and Arch Linux as daily drivers on different machines.
My preferred window manager is Sway (`x86_64` Wayland) and I don't own NVIDIA
GPUs so don't expect any proprietary driver configurations or obsessive
performance optimisations. My tenure in the terminal (`alacritty` with ~~`tmux`~~ `zellij`)
outweighs any focus on graphical interfaces, which are not well suited to the
spartan development conditions of Open Source.

Most or all of my shell scripts should be self sufficient, written in either
Python, Nim, POSIX or zsh shell, and are likely the most portable components.
They can be found in the `.local/bin/` folder, e.g.

- [doi2bib](https://git.sr.ht/~adigitoleo/dotconf/tree/master/item/.local/bin/doi2bib),
  a bibliographic metadata querying tool using the CrossRef API,
- [musicplayer](https://git.sr.ht/~adigitoleo/dotconf/tree/master/item/.local/bin/musicplayer),
  an extremely simple music player TUI using [fzf](https://github.com/junegunn/fzf), among others...

My <200 line .zshrc sets up asynchronous Git status indicators and is aware of
remote login sessions, and my rather more unwieldy NeoVim configuration (900+
lines of `.config/nvim/init.lua` not counting filetype specific features in
`.config/nvim/after/`) provides comprehensive code linting, Git integration,
and general IDE features (including floating terminals, without any plugin).

For more about me,
you can check [my website](https://adigitoleo.srht.site/about-me/),
which lists any more substantial projects and
might eventually host articles worth reading...
