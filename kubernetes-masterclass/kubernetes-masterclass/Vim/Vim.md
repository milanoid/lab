- https://www.lazyvim.org/

 `.vimrc`

```
" Ensure Vim uses filetype plugins
filetype plugin on


" Enable indentation
filetype indent on


" Set the default indentation to 2 spaces for all files
set tabstop=2
set softtabstop=2
set shiftwidth=2
set expandtab


" Highlight trailing whitespace in all files
autocmd BufRead,BufNewFile * match Error /\s\+$/


" Enable auto-indentation
set autoindent


" Turn on syntax highlighting
syntax on


" Set backspace so it acts more intuitively
set backspace=indent,eol,start
```
## Modes

- `v` Visual
- `i` Insert



## Undo

`u` - undo

## Edit

Find a string `test` and replace it with `frontend` and do it globally (`g`)

`%s/test/frontend/g` 

## Copy & Paste

enter Visual mode `v`, select what to copy, press `y` for copy
switch to Insert mode `i`, and then `p` for paste


- keeping a yaml formatting while copy'n'pasting (could be in `~/.vimrc`)

`:set paste`

#### copy everything from top to bottom
- `shift+v` then `shift+g`
- `y` for yank (copy)
- `p` for paste

## Two files in panels

`vim -O file1 file2`

- switch between panels `ctrl+w`, then `l` (right) or `h` (left)
