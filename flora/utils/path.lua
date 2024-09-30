---
--- @class flora.utils.Path
---
local Path = Class:extend("Path", ...)

-- sloppily ported over from haxe itself
-- https://github.com/HaxeFoundation/haxe/blob/4.3.1/std/haxe/io/Path.hx

-- probs gonna be majorly untested, sorry :(
    
function Path:constructor(p)
    self.dir = nil
    self.file = nil
    self.ext = nil
    self.backslash = false

    if p == "." or p == ".." then
        self.dir = p
        self.file = ""
        return
    end

    local c1 = string.lastIndexOf(p, "/")
    local c2 = string.lastIndexOf(p, "\\")

    if c1 < c2 then
        self.dir = string.sub(p, 1, c2 - 1)
        p = string.sub(p, c2 + 1)
        self.backslash = true
    elseif c2 < c1 then
        self.dir = string.sub(p, 1, c1 - 1)
        p = string.sub(p, c1 + 1)
    else
        self.dir = nil
    end

    local cp = string.lastIndexOf(p, ".")
    if cp ~= -1 then
        self.ext = string.sub(p, cp + 1)
        self.file = string.sub(p, 1, cp - 1)
    else
        self.ext = nil
        self.file = p
    end
end

function Path:__tostring()
    local final = (self.dir == nil) and "" or self.dir .. (self.backslash and "\\" or "/")
    final = final .. self.file
    if self.ext ~= nil then
        final = final .. self.ext
    end
    return final
end

function Path.withoutExtension(p)
    local s = Path:new(p)
    s.ext = nil
    return s:__tostring()
end

function Path.withoutDirectory(p)
    local s = Path:new(p)
    s.dir = nil
    return s:__tostring()
end

function Path.directory(p)
    local s = Path:new(p)
    return s.dir ~= nil and s.dir or ""
end

function Path.extension(p)
    local s = Path:new(p)
    return s.ext ~= nil and s.ext or ""
end

function Path.withExtension(p, ext)
    local s = Path:new(p)
    s.ext = ext
    return s:__tostring()
end

function Path.join(_paths)
    local paths = table.filter(_paths, function(s) return s ~= nil and s ~= "" end)
    if #paths < 1 then
        return ""
    end
    local p = paths[1]
    for i = 2, #paths do
        p = Path.addTrailingSlash(p)
        p = p .. paths[i]
    end
    return Path.normalize(p)
end

function Path.normalize(p)
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
            if #target > 0 or string.charCodeAt(p, 0) == slashCode then
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
        local char = string.charAt(tmp, i)
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

function Path.addTrailingSlash(p)
    if #p < 1 then
        return "/"
    end

    local c1 = string.lastIndexOf(p, "/")
    local c2 = string.lastIndexOf(p, "\\")

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

function Path.removeTrailingSlashes(path)
    local slashCode = string.byte("/")
    local backSlashCode = string.byte("\\")
    while true do
        local code = string.charCodeAt(path, #path)
        if code == slashCode or code == backSlashCode then
            path = string.sub(path, 1, #path - 1)
        else
            break
        end
    end
    return path
end

function Path.isAbsolute(p)
    if string.startsWith(p, "/") then
        return true
    end
    if string.charAt(p, 0) == ":" then
        return true
    end
    if string.startsWith(p, "\\\\") then
        return true
    end
    return false
end

return Path