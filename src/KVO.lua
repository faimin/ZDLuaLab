---
--- Generated by EmmyLua(https://github.com/EmmyLua)
--- Created by Zero.
--- DateTime: 2019-05-25 16:53
---

--[[
	valueChangeFunc(key, oldValue, newValue)
	http://lua-users.org/wiki/GeneralizedPairsAndIpairs
]]--
function lua_kvo(tbl, valueChangeFunc)
    if not tbl then
        return
    end

    if not trackKey then
        assert(trackKey, "你想监听的key为nil，推荐以`table[key]`的形式设置")
    end

    local proxy = {}

    local proxy_metable = {
        __index = function(_, k)
            return tbl[k]
        end,

        __newindex = function(_, k, v)
            if not k then
                print("lua_kvo => key为nil : ", k)
            end

            local oldValue = tbl[k]
            tbl[k] = v

            if valueChangeFunc then
                valueChangeFunc(k, oldValue, v)
            end
            --print("lua_kvo => set, key = ", k, "oldValue = ", oldValue, "newValue = ", v)
        end,

        __pairs = function()
            return function(_, k)
                local nextkey, nextvalue = next(tbl, k)
                --print("lua_kvo => pairs: ", nextkey, nextvalue)
                return nextkey, nextvalue
            end
        end,

        __ipairs = function()
            local function iter(tbl, i)
                i = i + 1
                local v = tbl[i]
                if v then
                    return i, v
                end
            end

            return iter, tbl, 0
        end,

        __len = function()
            return #tbl
        end
    }

    setmetatable(proxy, proxy_metable)

    return proxy
end

--[[
-- 测试代码
local _class = {}

function _class:new()
	local class = {}
	class["key"] = "value"
	setmetatable(class, self)
	return self
end

newTable = _class:new()
key = "key"
newTable.key = "100"
newTable.name = "zero"
--newTable[1] = 334
--newTable[2] = 2535
newTable = track(newTable, key, function(k, oldV, newV)
	print("第一", k, oldV, newV)
end)
newTable.key = 1123
--newTable[1] = "wggagsd"

newTable = track(newTable, a, function(k, oldV, newV)
	print("第2️⃣", k, oldV, newV)
end)
newTable.a = "a"
newTable.b = "ssss"
newTable.a = "weaw"

--for i, v in ipairs(newTable) do
--	print(i, v)
--end

return _class
]]--