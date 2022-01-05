-- TODO Send PR for some of these
return {
    extension = {
        ['r'] = 'r',  -- NOTE Lower case `r` extension. Upper case doesn't work.
    },
    file_name = {  -- TODO Need? And validate TODO Check duplicates with base.lua, etc
        ['DESCRIPTION'] = 'yaml',
        ['renv.lock'] = 'json',
        ['.tmux.conf'] = 'tmux',
        ['NAMESPACE'] = 'r',
        ['.radian_profile'] = 'r',
        ['.lintr'] = 'r',
    }
}
