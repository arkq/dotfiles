" initialize package manager
source ~/.config/nvim/plug.vim

colorscheme desert-warm-256

filetype plugin indent on
set autoindent
set smarttab
set tabstop=2
set shiftwidth=2
set softtabstop=2
set textwidth=98

set title
set mousemodel=extend
set nomousehide

" terminal enhancements
set lazyredraw
set ttyfast

" quick command line mode
nnoremap ; :
vnoremap ; :

" make vertical diff by default
set diffopt+=vertical

set spell
set spelllang=en_us
set spellfile=~/.config/nvim/spell.add
nnoremap <F7> :setlocal spell! spell?<CR>

set pastetoggle=<F12>
set hidden
set number
set modeline
set mouse=a

" enhanced command-line
set wildignorecase
set wildmenu

" completion menu improvement
set completeopt=longest,menuone

" IO latency workaround
set updatetime=750
set directory=/tmp

" smart-ass search mode
set incsearch
set ignorecase
set smartcase
set hlsearch

" nice line wrapping
set linebreak
set breakindent

" folding tweaks
set foldlevel=666
nnoremap <space> za

" splits tweaks
set splitbelow
set splitright

" change the leader from \ to ,
let mapleader = ','

" syntax tweaks
let c_space_errors = 1
let python_space_errors = 1
let python_highlight_all = 1

"""
""" settings for plug-ins

let g:AutoPairsCenterLine = 0

let g:airline#extensions#disable_rtp_load = 1
let g:airline#extensions#whitespace#mixed_indent_algo = 2
let g:airline_detect_spell = 0

let g:deoplete#enable_at_startup = 1

let g:fuzzy_hidden = 1

let g:gitgutter_enabled = 0
let g:gitgutter_override_sign_column_highlight = 0
let g:gitgutter_escape_grep = 1
let g:gitgutter_map_keys = 0

let g:Illuminate_delay = 750
let g:Illuminate_ftblacklist = ['nerdtree']

let g:javascript_plugin_jsdoc = 1

let g:lsp_document_highlight_enabled = 0

let vim_markdown_preview_github = 1
let vim_markdown_preview_use_xdg_open = 1
let g:vim_markdown_strikethrough = 1

" exclude intermediate files from the tree
let NERDTreeIgnore = ['\.o$', '\.py[co]$', '^__pycache__$']
" use our fold/unfold key for tree expansion
let NERDTreeMapActivateNode = '<space>'

" non-TAB based snippet expansion
let g:UltiSnipsExpandTrigger = '<C-j>'

" keep Copilot disabled by default
let b:copilot_enabled = 0
nmap <leader>C :let b:copilot_enabled = !b:copilot_enabled<CR>

" search current word on the web
nmap <leader>g <Plug>(openbrowser-smart-search)
vmap <leader>g <Plug>(openbrowser-smart-search)

" search current word in subdirectories
nmap <leader>f :Ggrep! -q <cword><CR>
nmap <leader>F :Rg <cword><CR>

nmap <silent><F2> :NERDTreeToggle<CR>
nmap <silent><F3> :GitGutterToggle<CR>
map <silent><F4> :Git blame<CR>
nmap <silent><F8> :TagbarToggle<CR>
nmap <silent><C-p> :FuzzyOpen<CR>
map <silent><C-_> :Commentary<CR>
map <leader>h :FSHere<CR>

" do not insert newline upon item selection in pop-up
inoremap <expr> <CR> pumvisible() ? "\<C-y>" : "\<C-g>u\<CR>"

" perform auto-import and formatting on save
let g:go_fmt_command = 'goimports'

" jedi-based completion for Python
let g:jedi#auto_vim_configuration = 0
let g:jedi#completions_enabled = 0
let g:jedi#show_call_signatures = 0
let g:jedi#smart_auto_mappings = 0
autocmd FileType python setlocal omnifunc=jedi#completions

" python automatic import sorting
autocmd FileType python map <C-i> :Isort<CR>

" customized background colors for git gutter symbols
highlight GitGutterAdd guibg=green ctermbg=green gui=bold cterm=bold
highlight GitGutterChange guibg=darkyellow ctermbg=darkyellow gui=bold cterm=bold
highlight GitGutterChangeDelete guibg=darkyellow ctermbg=darkyellow gui=bold cterm=bold
highlight GitGutterDelete guibg=darkred ctermbg=darkred gui=bold cterm=bold
