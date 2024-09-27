---
--- @class flora.utils.file
---
local file = class:extend()

function file.save(file_path, content)
    local success, _ = love.filesystem.write(file_path, content)
    return success
end

function file.read(file_path)
    local contents, _ = love.filesystem.read(file_path)
    return contents
end

function file.file_exists(file_path)
    return love.filesystem.getInfo(file_path, "file") ~= nil
end

function file.dir_exists(file_path)
    return love.filesystem.getInfo(file_path, "directory") ~= nil
end

function file.exists(file_path)
    return file.file_exists(file_path) or file.dir_exists(file_path)
end

function file.get_files_in_dir(directory)
    return love.filesystem.getDirectoryItems(directory)
end

function file.load_script_chunk(file)
    return love.filesystem.load(file)
end

return file