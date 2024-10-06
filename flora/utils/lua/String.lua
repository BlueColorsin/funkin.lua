--- Splits a `string` at each occurrence of `delimiter`.
---
--- @param str       string  The string to split.
--- @param delimiter string  The delimiter to split the string by.
---
function string.split(str, delimiter)
    local result = {}
    local regex = ("([^%s]+)"):format(delimiter)
    for each in str:gmatch(regex) do
        table.insert(result, each)
    end
    return result
end

--- Trims the left and right ends of this `string`
--- to remove invalid characters.
---
---@param string string  The string to trim.
---
function string.trim(string)
    return string:gsub("^%s*(.-)%s*$", "%1")
end

--- Returns if the contents of a `string` contains the
--- contents of another `string`. 
---
--- @param string string  The string to check.
--- @param value  string  What `string` should contain.
---
function string.contains(string, value)
    return string:find(value, 1, true) ~= nil
end

--- Returns if the contents of a `string` starts with the
--- contents of another `string`. 
---
--- @param string string  The string to check.
--- @param start  string  What `string` should start with.
---
function string.startsWith(string, start)
    return string:sub(1, #start) == start
end

--- Returns if the contents of a `string` ends with the
--- contents of another `string`. 
---
--- @param string string  The string to check.
--- @param ending string  What `string` should end with.
---
function string.endsWith(string, ending)
    return ending == "" or string:sub(-#ending) == ending
end

---
--- Gets the last occurrence of `sub` in the string of `str`
--- and returns the index of it.
---
---@param str string  The main string in which you want to find the last index of the `sub`.
---@param sub string  The substring for which you want to find the last index in the `str`.
---
function string.lastIndexOf(str, sub)
    local subStringLength = #sub
    local lastIndex = -1

    for i = 1, #str - subStringLength + 1 do
        local currentSubstring = str:sub(i, i + subStringLength - 1)
        if currentSubstring == sub then
            lastIndex = i
        end
    end

    return lastIndex
end

--- Replaces all occurrences of `from` in a `string` with
--- the contents of `to`.
---
--- @param string string  The string to check.
--- @param from   string  The content to be replaced with `to`.
--- @param to     string  The content to replace `from` with.
---
function string.replace(string, from, to)
    local searchStartIdx = 1

    while true do
        local startIdx, endIdx = string:find(from, searchStartIdx, true)
        if (not startIdx) then
            break
        end

        local postfix = string:sub(endIdx + 1)
        string = string:sub(1, (startIdx - 1)) .. to .. postfix

        searchStartIdx = -1 * postfix:len()
    end

    return string
end

--- Inserts any given string into another `string`
--- starting at a given character position.

--- @param string string   The string to have content inserted into.
--- @param pos    integer  The character position to insert the new content.
--- @param text   string   The content to insert.
---
function string.insert(string, pos, text)
    return string:sub(1, pos - 1) .. text .. string:sub(pos)
end

---
--- Returns the character of a given string
--- at a certain position of said string.
---
---@param str string   The string to get this character from.
---@param pos integer  The position of the character to get.
---
function string.charAt(str, pos)
    return string.sub(str, pos, pos)
end

---
--- Similar to `string.charAt()` but it returns the raw character
--- code of the returned character.
---
---@param str string   The string to get this character code from.
---@param pos integer  The position of the character code to get.
---
function string.charCodeAt(str, pos)
    return string.byte(string.charAt(str, pos))
end

--- Pads a given string with a given character
--- (default: whitespace) up to a certain length
--- on the left side of the string.
---
--- @param  str     string   The string to pad.
--- @param  length  integer  The length to pad the string to.
--- @param  char    string   The character to pad the string with. (default: whitespace)
---
function string.lpad(str, length, char)
    return string.rep(char or ' ', length - #str) .. str
end

--- Pads a given string with a given character
--- (default: whitespace) up to a certain length
--- on the right side of the string.
---
--- @param  str     string   The string to pad.
--- @param  length  integer  The length to pad the string to.
--- @param  char    string   The character to pad the string with. (default: whitespace)
---
function string.rpad(str, length, char)
    return str .. string.rep(char or ' ', length - #str)
end

return {}