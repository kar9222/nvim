local iron = require('iron')

iron.core.add_repl_definitions {
    r = { radian = { command = {'radian'} } },
    julia = { mycustom = { command = {'radian'} } }
}

iron.core.set_config {
    preferred = {
        r = 'radian',
        julia = 'julia'
    },
    repl_open_cmd = 'vertical split'
}
