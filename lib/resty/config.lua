-- Copyright (c) 2018, Souche Inc.

local cjson = require "cjson.safe"
local fs = require "fs"
local Object = require "utility.object"

local function cluster()
    local is_worker = pcall(function() 
        ngx.timer.at(0, function() end) 
    end)

    if is_worker then
        return "worker"
    else
        return "master"
    end
end

local Config = {
    path = ngx.config.prefix() .. "config",
    exts = {
        lua = function(path)
            return loadfile(path)()
        end,
        json = function(path)
            local file, err = fs.read(path)
    
            if file then
                return cjson.decode(file)
            else
                return nil, err
            end
        end
    },
    __cache = {}
}

setmetatable(Config, {
    __call = function(self)
        local filename = self.path .. "/" .. cluster()
        
        for ext, handler in pairs(self.exts) do
            local file = filename .. "." .. ext
            if self.__cache[file] then return self.__cache[file] end

            if fs.isFile(file) then
                local config, err = handler(file)
                
                if not config then 
                    return nil, err
                else
                    self.__cache[file] = config
                    return config
                end
            end
        end

        return nil, "cannot find config: " .. filename .. " with exts: " .. Object.keys(self.exts):join("|")
    end
})

return Config
