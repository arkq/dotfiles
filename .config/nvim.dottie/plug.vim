" plug.vim: vim-plug startup
"
" Kick-start command:
" curl -fLo ~/.config/nvim/autoload/plug.vim --create-dirs \
"   https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim

call plug#begin('~/.config/nvim/plugged')

" Defaults everyone can agree on
Plug 'tpope/vim-sensible'

" Use capabilities of modern terminals
Plug 'rainux/vim-desert-warm-256'

" Make Vim to be more IDE-like
Plug 'bling/vim-airline'
Plug 'majutsushi/tagbar'
Plug 'scrooloose/nerdtree', { 'on': 'NERDTreeToggle' }

" Git integration
Plug 'airblade/vim-gitgutter', { 'on': 'GitGutterToggle' }
Plug 'tpope/vim-fugitive'

" Indentation automatic detection
Plug 'vim-scripts/yaifa.vim'

" Line and column jumper
Plug 'kopischke/vim-fetch'

" Switch between source and header
Plug 'derekwyatt/vim-fswitch'

" Bucket full of snippets
if has('python')
	Plug 'SirVer/ultisnips'
	Plug 'honza/vim-snippets'
endif

" Keyword completion system
if has('nvim')
	Plug 'Shougo/deoplete.nvim'
	Plug 'zchee/deoplete-jedi', { 'for': 'python' }
	let Completion#start = function('deoplete#mappings#manual_complete')
	let Completion#stop = function('deoplete#mappings#close_popup')
else
	Plug 'Shougo/vimproc.vim', { 'do': 'make' }
	Plug 'Shougo/context_filetype.vim'
	Plug 'Shougo/neoinclude.vim'
	Plug 'Shougo/neocomplete.vim'
	let Completion#start = function('neocomplete#start_manual_complete')
	let Completion#stop = function('neocomplete#close_popup')
endif
if has('python')
	Plug 'Rip-Rip/clang_complete'
endif

" Syntax (compilation & code style) checker
Plug 'ntpeters/vim-better-whitespace'
Plug 'scrooloose/syntastic'

" Comment-out code as a champ
Plug 'tpope/vim-commentary'

" User-friendly brackets and quotations
Plug 'jiangmiao/auto-pairs'
Plug 'tpope/vim-surround'
Plug 'vim-scripts/matchit.zip'

Plug 'hynek/vim-python-pep8-indent', { 'for': 'python' }
Plug 'vim-scripts/python_fold', { 'for': 'python' }
if has('python')
	Plug 'davidhalter/jedi-vim', { 'for': 'python' }
	Plug 'fisadev/vim-isort', { 'for': 'python' }
endif

Plug 'JamshedVesuna/vim-markdown-preview'
Plug 'artoj/qmake-syntax-vim'
Plug 'fatih/vim-go', { 'for': 'go' }
Plug 'jeroenbourgois/vim-actionscript'
Plug 'vim-scripts/HTML-AutoCloseTag'

call plug#end()
