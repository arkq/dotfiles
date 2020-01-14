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
set spellfile=~/.vim/spell.add
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
let g:deoplete#enable_at_startup = 1
let g:deoplete#disable_auto_complete = 1
let g:airline#extensions#disable_rtp_load = 1
let g:airline#extensions#whitespace#mixed_indent_algo = 1

let g:gitgutter_enabled = 0
let g:gitgutter_override_sign_column_highlight = 0
let g:gitgutter_escape_grep = 1
let g:gitgutter_map_keys = 0

let g:javascript_plugin_jsdoc = 1

let vim_markdown_preview_github = 1
let vim_markdown_preview_use_xdg_open = 1

" exclude intermediate files from the tree
let NERDTreeIgnore = ['\.o$', '\.py[co]$', '^__pycache__$']
" use our fold/unfold key for tree expansion
let NERDTreeMapActivateNode = '<space>'

" non-TAB based snippet expansion
let g:UltiSnipsExpandTrigger = '<C-j>'

" search current word on the web
nmap <leader>g <Plug>(openbrowser-smart-search)
vmap <leader>g <Plug>(openbrowser-smart-search)

let g:syntastic_check_on_wq = 0
let g:syntastic_c_compiler_options = '-Wall -Wextra'
let g:syntastic_c_config_file = '.clang_complete'
let g:syntastic_cpp_compiler_options = '-Wall -Wextra'
let g:syntastic_cpp_config_file = '.clang_complete'
let g:syntastic_python_flake8_args = '--ignore=E501,W191'

" smart TAB completion
inoremap <expr><Tab> pumvisible() ? "\<C-n>" :
	\ <SID>startswithspace() ? "\<Tab>" : deoplete#manual_complete()
inoremap <expr><S-Tab> pumvisible() ? "\<C-p>" : "\<S-Tab>"
function! s:startswithspace()
	let col = col('.') - 1
	return !col || getline('.')[col - 1] =~ '\s'
endfunction

" do not insert <CR> upon item selection
inoremap <expr><CR> <SID>customcrfunction()
function! s:customcrfunction()
	return pumvisible() ? deoplete#close_popup() : "\<CR>"
endfunction

" auto-pairs workaround for buggy <CR> mapping
let g:AutoPairsMapCR = 0
imap <silent><CR> <CR><Plug>AutoPairsReturn

nmap <silent><F2> :NERDTreeToggle<CR>
nmap <silent><F3> :GitGutterToggle<CR>
map <silent><F4> :Gblame<CR>
nmap <silent><F8> :TagbarToggle<CR>
nmap <silent><C-p> :FuzzyOpen<CR>
map <silent><C-_> :Commentary<CR>
map <leader>h :FSHere<CR>

" clang-based completion for C and C++
let g:deoplete#sources#clang#libclang_path = '/usr/lib/llvm/8/lib64/libclang.so'
let g:deoplete#sources#clang#clang_header = '/usr/lib/llvm/'

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
