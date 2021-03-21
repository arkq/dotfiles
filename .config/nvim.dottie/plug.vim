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

" Various handy GUI helpers
Plug 'equalsraf/neovim-qt', { 'rtp': 'src/gui/runtime' }

" Make Vim to be more IDE-like
Plug 'bling/vim-airline'
Plug 'majutsushi/tagbar'
Plug 'cloudhead/neovim-fuzzy'
Plug 'scrooloose/nerdtree', { 'on': 'NERDTreeToggle' }

" Complete anything with a TAB key
Plug 'ackyshake/VimCompletesMe'

" Whitespace highlighting
Plug 'ntpeters/vim-better-whitespace'

" Highlight word under cursor
Plug 'RRethy/vim-illuminate'

" Git integration
Plug 'airblade/vim-gitgutter', { 'on': 'GitGutterToggle' }
Plug 'tpope/vim-fugitive'

" Hex editing in Vim
Plug 'fidian/hexmode'
Plug 'rr-/vim-hexdec'

" Indentation automatic detection
Plug 'vim-scripts/yaifa.vim'

" Line and column jumper
Plug 'kopischke/vim-fetch'

" Switch between source and header
Plug 'derekwyatt/vim-fswitch'

" Bucket full of snippets
Plug 'SirVer/ultisnips'
Plug 'honza/vim-snippets'

" Keyword completion system
Plug 'Shougo/deoplete.nvim'
Plug 'zchee/deoplete-clang', { 'for': ['c', 'cpp'] }
Plug 'zchee/deoplete-jedi', { 'for': 'python' }

" Syntax (compilation & code style) checker
Plug 'scrooloose/syntastic'

" Comment-out code as a champ
Plug 'tpope/vim-commentary'

" User-friendly brackets and quotations
Plug 'jiangmiao/auto-pairs'
Plug 'tpope/vim-surround'
Plug 'vim-scripts/matchit.zip'

" Open URI with favorite browser
Plug 'tyru/open-browser.vim'

" Python Development Environment
Plug 'hynek/vim-python-pep8-indent', { 'for': 'python' }
Plug 'vim-scripts/python_fold', { 'for': 'python' }
Plug 'davidhalter/jedi-vim', { 'for': 'python' }
Plug 'fisadev/vim-isort', { 'for': 'python' }

" Markdown WYSIWYG
Plug 'plasticboy/vim-markdown', { 'for': 'markdown' }
Plug 'JamshedVesuna/vim-markdown-preview', { 'for': 'markdown' }

Plug 'artoj/qmake-syntax-vim', { 'for': 'qmake' }
Plug 'fatih/vim-go', { 'for': 'go' }
Plug 'jeroenbourgois/vim-actionscript', { 'for': 'actionscript' }
Plug 'pangloss/vim-javascript', { 'for': 'javascript' }
Plug 'vim-scripts/HTML-AutoCloseTag'

call plug#end()
