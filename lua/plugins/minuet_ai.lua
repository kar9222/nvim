require'minuet'.setup{
    -- Enable or disable auto-completion. Note that you still need to add
    -- Minuet to your cmp/blink sources. This option controls whether cmp/blink
    -- will attempt to invoke minuet when minuet is included in cmp/blink
    -- sources. This setting has no effect on manual completion; Minuet will
    -- always be enabled when invoked manually. You can use the command
    -- `Minuet cmp/blink toggle` to toggle this option.
    cmp = {
        enable_auto_complete = true,
    },
    -- blink = {
    --     enable_auto_complete = true,
    -- },
    -- LSP is recommended only for built-in completion. If you are using
    -- `cmp` or `blink`, utilizing LSP for code completion from Minuet is *not*
    -- recommended.
    lsp = {
        enabled_ft = {},
        -- Filetypes excluded from LSP activation. Useful when `enabled_ft` = { '*' }
        disabled_ft = {},
        -- Enables automatic completion triggering using `vim.lsp.completion.enable`
        enabled_auto_trigger_ft = {},
        -- Filetypes excluded from autotriggering. Useful when `enabled_auto_trigger_ft` = { '*' }
        disabled_auto_trigger_ft = {},
        -- if true, warn the user that they should use the native source
        -- instead when the user is using blink or nvim-cmp.
        warn_on_blink_or_cmp = true,
        -- See README section [Built-in Completion, Mini.Completion, and LSP
        -- Setup] for more details on this option.
        adjust_indentation = true,
    },
    virtualtext = {
        -- Specify the filetypes to enable automatic virtual text completion,
        -- e.g., { 'python', 'lua' }. Note that you can still invoke manual
        -- completion even if the filetype is not on your auto_trigger_ft list.
        auto_trigger_ft = {},
        -- specify file types where automatic virtual text completion should be
        -- disabled. This option is useful when auto-completion is enabled for
        -- all file types i.e., when auto_trigger_ft = { '*' }
        auto_trigger_ignore_ft = {},
        keymap = {
            -- accept whole completion
            accept = '<A-A>',
            -- accept one line
            accept_line = '<A-a>',
            -- accept n lines (prompts for number)
            -- e.g. "A-z 2 CR" will accept 2 lines
            accept_n_lines = '<A-z>',
            -- Cycle to prev completion item, or manually invoke completion
            prev = '<A-[>',
            -- Cycle to next completion item, or manually invoke completion
            next = '<A-]>',
            dismiss = '<A-e>',
        },
        -- Whether show virtual text suggestion when the completion menu
        -- (nvim-cmp or blink-cmp) is visible.
        show_on_completion_menu = false,
    },

    -- The maximum total characters of the context before and after the cursor
    -- 16000 characters typically equate to approximately 4,000 tokens for LLMs.
    context_window = 16000,

    -- When the total characters exceed the context window, the ratio of
    -- context before cursor and after cursor, the larger the ratio the more
    -- context before cursor will be used. This option should be between 0 and
    -- 1, context_ratio = 0.75 means the ratio will be 3:1.
    context_ratio = 0.75,

    -- Only send the request every x milliseconds, use 0 to disable throttle.
    -- Increase to reduce costs and avoid rate limits (e.g. increase to 1500)
    throttle = 1000,

    -- Debounce the request in x milliseconds, set to 0 to disable debounce
    -- Increase to reduce costs and avoid rate limits (e.g. increase to 600)
    debounce = 400,

    -- Control notification display for request status. Notification options:
    -- false:     Disable all notifications (use boolean false, not string "false")
    -- "debug":   Display all notifications (comprehensive debugging)
    -- "verbose": Display most notifications
    -- "warn":    Display warnings and errors only
    -- "error":   Display errors only
    notify = 'warn',

    -- Request timeout, measured in seconds. When streaming is enabled
    -- (stream = true), setting a shorter request_timeout allows for faster
    -- retrieval of completion items, albeit potentially incomplete.
    -- Conversely, with streaming disabled (stream = false), a timeout
    -- occurring before the LLM returns results will yield no completion items.
    request_timeout = 3,

    -- If completion item has multiple lines, create another completion item
    -- only containing its first line. This option only has impact for cmp and blink.
    -- For virtualtext, no single line entry will be added.
    add_single_line_entry = true,

    -- The number of completion items encoded as part of the prompt for the
    -- chat LLM. For FIM model, this is the number of requests to send. It's
    -- important to note that when 'add_single_line_entry' is set to true, the
    -- actual number of returned items may exceed this value. Additionally, the
    -- LLM cannot guarantee the exact number of completion items specified, as
    -- this parameter serves only as a prompt guideline.
    n_completions = 3,

    -- Length of context after cursor used to filter completion text.
    --
    -- This setting helps prevent the language model from generating redundant
    -- text. When filtering completions, the system compares the suffix of a
    -- completion candidate with the text immediately following the cursor.
    --
    -- If the length of the longest common substring between the end of the
    -- candidate and the beginning of the post-cursor context exceeds this
    -- value, that common portion is trimmed from the candidate.
    --
    -- For example, if the value is 15, and a completion candidate ends with a
    -- 20-character string that exactly matches the 20 characters following the
    -- cursor, the candidate will be truncated by those 20 characters before
    -- being delivered.
    after_cursor_filter_length = 15,

    -- Similar to after_cursor_filter_length but trim the completion item from
    -- prefix instead of suffix.
    before_cursor_filter_length = 2,

    -- proxy port to use
    proxy = nil,

    -- **List** of functions to execute. If any function returns `false`, Minuet
    -- will not trigger auto-completion. Manual completion can still be invoked,
    -- even if these functions evaluate to `false`, when using `nvim-cmp`,
    -- `blink-cmp`, or virtual text (excluding LSP).
    -- When this list is empty (the default), it always evaluates to `true`.
    -- Note that this is called each time Minuet attempts to trigger
    -- auto-completion, so ensure the functions in this list are highly efficient.
    enable_predicates = {},

    -- see the documentation in the `Prompt` section
    default_system = {
        template              = '...',
        prompt                = '...',
        guidelines            = '...',
        n_completion_template = '...',
    },
    default_system_prefix_first = {
        template              = '...',
        prompt                = '...',
        guidelines            = '...',
        n_completion_template = '...',
    },
    default_fim_template = {
        prompt = '...',
        suffix = '...',
    },
    default_few_shots = { '...' },
    default_chat_input = { '...' },
    default_few_shots_prefix_first = { '...' },
    default_chat_input_prefix_first = { '...' },
    -- Config options for `Minuet change_preset` command
    presets = {},

    -- Provider ----------------------------------------

    provider = 'openai_compatible',
    -- NOTE The `name` must match `kind_icons` in cmp.lua
    provider_options = {
        openai_compatible = {
            api_key = 'OPENROUTER_API_KEY',
            end_point = 'https://openrouter.ai/api/v1/chat/completions',
            model = 'moonshotai/kimi-k2',
            name = 'OpenRouter',
            optional = {
                max_tokens = 56,
                top_p = 0.9,
                provider = {
                     -- Prioritize throughput for faster completion
                    sort = 'throughput',
                },
            },
        },
    },
}
