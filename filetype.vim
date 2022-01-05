" Custom file types

if exists('did_load_filetypes') | finish | endif

augroup FiletypeDetect
    au! BufRead,BufNewFile DESCRIPTION setfiletype yaml
    au! BufRead,BufNewFile renv.lock setfiletype json
    au! BufRead,BufNewFile .Rprofile,NAMESPACE,.radian_profile,.lintr setfiletype r
augroup END
