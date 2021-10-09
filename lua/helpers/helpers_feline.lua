-- Adapted from feline.nvim by Famiu Haque. All the credits go to him. See [famiu/feline.nvim](https://github.com/famiu/feline.nvim)
-- Specifically, I extracted parts of the functions for my status line.

local fn = vim.fn

local M = {}

-- Get the names of all current listed buffers
local function get_current_filenames()
    local listed_buffers = vim.tbl_filter(
        function(buffer)
            return buffer.listed == 1
        end,
        fn.getbufinfo()
    )

    return vim.tbl_map(function(buffer) return buffer.name end, listed_buffers)
end

-- Get unique name for the current buffer
function M.get_unique_filename(filename)
    local filenames = vim.tbl_filter(
        function(filename_other)
            return filename_other ~= filename
        end,
        get_current_filenames()
    )

    filename = string.reverse(filename)

    local index

    if next(filenames) then
        filenames = vim.tbl_map(string.reverse, filenames)

        index = math.max(unpack(vim.tbl_map(
            function(filename_other)
                for i = 1, #filename do
                    if filename:sub(i, i) ~= filename_other:sub(i, i) then
                        return i
                    end
                end
                return 1
            end,
            filenames
        )))
    else
        index = 1
    end

    while index <= #filename do
        if filename:sub(index, index) == "/" then
            index = index - 1
            break
        end

        index = index + 1
    end

    return string.reverse(string.sub(filename, 1, index))

end

return M
