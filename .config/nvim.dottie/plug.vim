" plug.vim: vim-plug startup
"
" Kick-start command:
" curl -fLo ~/.vim/autoload/plug.vim --create-dirs \
"   https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim

call plug#begin('~/.config/nvim/plugged')

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

" Bucket full of snippets
Plug 'SirVer/ultisnips'
Plug 'honza/vim-snippets'

" Keyword completion system
Plug 'Shougo/vimproc.vim'
Plug 'Shougo/context_filetype.vim'
Plug 'Shougo/neoinclude.vim'
Plug 'Shougo/neocomplete.vim'

" Syntax (compilation & code style) checker
Plug 'scrooloose/syntastic'

" User-friendly brackets and quotations
Plug 'jiangmiao/auto-pairs'
Plug 'tpope/vim-surround'
Plug 'vim-scripts/matchit.zip'

if has('python')
	Plug 'Rip-Rip/clang_complete'
endif

Plug 'hynek/vim-python-pep8-indent', { 'for': 'python' }
Plug 'vim-scripts/python_fold', { 'for': 'python' }
if has('python')
	Plug 'davidhalter/jedi-vim', { 'for': 'python' }
	Plug 'fisadev/vim-isort', { 'for': 'python' }
endif

Plug 'vim-scripts/HTML-AutoCloseTag'

call plug#end()
