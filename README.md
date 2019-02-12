# lua-resty-config

[![MIT](https://img.shields.io/badge/license-MIT-blue.svg)](https://git.souche-inc.com/xieda/lua-resty-config/blob/master/LICENSE)

> [ngx.timer.at](https://github.com/openresty/lua-nginx-module#ngxtimerat) 不能在 init_by_lua 阶段使用

## Requirements

* cjson
* lua-utility
* lua-fs-module

## Usage

```lua
-- {ngx.config.prefix()}/config/master.lua
return {
  isMaster = true
}
```

```json
// {ngx.config.prefix()}/config/worker.json
{
  "isMaster": false
}
```

```lua
-- in master
local config = require "resty.config" ()
-- true
print(config.isMaster)

-- in worker
local config = require "resty.config" ()
-- false
print(config.isMaster)
```

## API

### Config.path

* ``<string>`` 配置文件目录，默认为 ``ngx.config.prefix() .. "config"``

### Config.exts

* ``<table>`` 配置文件加载策略
  * ``Config.exts.lua`` ``<function>`` lua 文件加载策略
  * ``Config.exts.json`` ``<function>`` json 文件加载策略

自定义加载策略

```ini
; {ngx.config.prefix()}/config/master.ini
isMaster=true
```

```lua
-- in master
local Config = require "resty.config"
local fs = require "fs"
local String = require "utility.string"

Config.exts.ini = function(path)
  local content, err = fs.readFile(path)
  if not content then return nil, err end

  return String.split(content, "\n"):reduce(function(config, str)
    str = String.trim(str)

    if String.startsWith(str, "[") then return config end

    local fragments = String.split(str, "=")
    config[fragments[1]] = fragments[2]

    return config
  end, {})
end

local config = Config()
-- true
print(config.isMaster)
```

## License

[MIT License](https://git.souche-inc.com/xieda/lua-resty-config/blob/master/LICENSE)

Copyright (c) 2018 xiedacon
