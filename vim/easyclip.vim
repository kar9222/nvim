" For modern versions of vim (Vim 8+ or Neovim) it has been split up into three different plugins instead: vim-cutlass, vim-yoink, and vim-subversive

" {vim-cutclass} ---------------------------------

nnoremap <leader>x d
xnoremap <leader>x d

nnoremap <leader>xx dd
nnoremap <leader>X D

" {vim-subversive} -------------------------------

nmap <leader>v <plug>(SubversiveSubstitute)
nmap <leader>vv <plug>(SubversiveSubstituteLine)
nmap <leader>V <plug>(SubversiveSubstituteToEndOfLine)

nmap <leader>r <plug>(SubversiveSubstituteRange)
xmap <leader>r <plug>(SubversiveSubstituteRange)
nmap <leader>rr <plug>(SubversiveSubstituteWordRange)

nmap <leader>rc <plug>(SubversiveSubstituteRangeConfirm)
xmap <leader>rc <plug>(SubversiveSubstituteRangeConfirm)
nmap <leader>rrc <plug>(SubversiveSubstituteWordRangeConfirm)

" TODO More stuffs. See docs.
