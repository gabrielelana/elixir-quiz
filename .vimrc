" autoload the local .vimrc file you need to have
" https://github.com/MarcWeber/vim-addon-local-vimrc
" plugin installed

let g:syntastic_elixir_checkers = ['elixir']
let g:syntastic_enable_elixir_checker = 1
let g:syntastic_mode_map = {'mode': 'passive', 'active_filetypes': ['elixir']}

nnoremap <silent> <Leader>r :exec '!elixir ' . expand('%p') <CR>
