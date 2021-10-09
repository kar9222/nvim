local M = {}

function M.dirname(path, remove_trail_sep)
    sep = package.config:sub(1, 1)  -- OS path separator
    local dir = path:match('(.*' .. sep .. ')')

    if remove_trail_sep == nil then
        remove_trail_sep = true
    end
    if remove_trail_sep == true then
        if string.sub(dir, -1, -1) == sep then
            dir = string.sub(dir, 1, -2)
        end
    end
    return dir
end

return M
