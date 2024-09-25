---
--- @class flora.utils.path
---
local path = class:extend()

-- sloppily ported over from haxe itself
-- https://github.com/HaxeFoundation/haxe/blob/4.3.1/std/haxe/io/Path.hx

-- probs gonna be majorly untested, sorry :(

function path:constructor(p)
    self.dir = nil
    self.file = nil
    self.ext = nil
    self.backslash = false

    if p == "." or p == ".." then
        self.dir = p
        self.file = ""
        return
    end

    local c1 = string.last_index_of(p, "/")
    local c2 = string.last_index_of(p, "\\")

    if c1 < c2 then
        self.dir = string.sub(p, 1, c2)
        self.path = string.sub(p, c2 + 1)
        self.backslash = true
    elseif c2 < c1 then
        self.dir = string.sub(p, 1, c1)
        self.path = string.sub(p, c1 + 1)
    else
        self.dir = nil
    end

    local cp = string.last_index_of(p, ".")
    if cp ~= -1 then
        self.ext = string.sub(p, cp + 1)
        self.file = string.sub(p, 1, cp - 1)
    else
        self.ext = nil
        self.file = p
    end
end

function path:__tostring()
    local final = (self.dir == nil) and "" or self.dir .. (self.backslash and "\\" or "/")
    final = final .. self.file
    if self.ext ~= nil then
        final = final .. self.ext
    end
    return final
end

function path.without_extension(p)
    local s = path:new(p)
    s.ext = nil
    return s:__tostring()
end

function path.without_directory(p)
    local s = path:new(p)
    s.dir = nil
    return s:__tostring()
end

function path.directory(p)
    local s = path:new(p)
    return s.dir ~= nil and s.dir or ""
end

function path.extension(p)
    local s = path:new(p)
    return s.ext ~= nil and s.ext or ""
end

function path.with_extension(p, ext)
    local s = path:new(p)
    s.ext = ext
    return s:__tostring()
end

function path.join(_paths)
    local paths = table.filter(_paths, function(s) return s ~= nil and s ~= "" end)
    if #paths < 1 then
        return ""
    end
    local p = paths[1]
    for i = 2, #paths do
        p = path.add_trailing_slash(p)
        p = p .. paths[i]
    end
    return path.normalize(p)
end

function path.normalize(p)
    local slash = "/"
    p = table.join(string.split(p, "\\"), slash)
    if p == slash then
        return slash
    end

    local target = {}
    local slashCode = string.byte("/")

    for _, token in ipairs(string.split(p, slash)) do
        if token == '..' and #target > 0 and target[#target] ~= ".." then
            table.remove(target, #target)
        elseif token == "" then
            if #target > 0 or string.char_code_at(p, 0) == slashCode then
                table.insert(target, token)
            end
        elseif token ~= "." then
            table.insert(target, token)
        end
    end

    local tmp = table.join(target, slash)
    local acc = ""
    local colon = false
    local slashes = false
    
    for i = 1, #tmp do
        local char = string.char_at(tmp, i)
        local code = string.byte(char)

        if code == string.byte(":") then
            acc = acc .. ":"
            colon = true
        
        elseif code == slashCode then
            if not colon then
                slashes = true
            end
        else
            colon = false
            if slashes then
                acc = acc .. "/"
                slashes = false
            end
            acc = acc .. char
        end
    end

    return acc
end

function path.add_trailing_slash(p)
    if #p < 1 then
        return "/"
    end

    local c1 = string.last_index_of(p, "/")
    local c2 = string.last_index_of(p, "\\")

    local final = p

    if c1 < c2 then
        if c2 ~= #p then
            final = final .. "\\"
        end
    else
        if c1 ~= #p then
            final = final .. "/"
        end
    end

    return final
end

function path.remove_trailing_slashes(path)
    local slashCode = string.byte("/")
    local backSlashCode = string.byte("\\")
    while true do
        local code = string.char_code_at(path, #path)
        if code == slashCode or code == backSlashCode then
            path = string.sub(path, 1, #path - 1)
        else
            break
        end
    end
    return path
end

function path.is_absolute(p)
    if string.starts_with(p, "/") then
        return true
    end
    if string.char_at(p, 0) == ":" then
        return true
    end
    if string.starts_with(p, "\\\\") then
        return true
    end
    return false
end

return path