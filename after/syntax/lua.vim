" TODO `end` keyword for function/if/etc. See runtime syntax file .../syntax/lua.vim

" String TODO Square brackets of `lua_function([[..]])`
hi link luaStringDelim Delimiter
syn match luaStringDelim "['"]"
syn region String matchgroup=luaStringDelim start=+'+ skip=+\\'+ end=+'+
syn region String matchgroup=luaStringDelim start=+"+ skip=+\\"+ end=+"+
