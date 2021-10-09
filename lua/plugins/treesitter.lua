local parser_configs = require('nvim-treesitter.parsers').get_parser_configs()

parser_configs.norg = {
    install_info = {
        url = "https://github.com/vhyrro/tree-sitter-norg",
        files = { "src/parser.c" },
        branch = "main"
    },
}

-- TODO Then run :TSInstall norg. If you want the parser to be more persistent across different installations of your config make sure to set norg as a parser in the ensure_installed table, then run :TSUpdate.
require('nvim-treesitter.configs').setup {
	ensure_installed = { "norg", "markdown" },
    -- highlight = {enable = true}
}
