---
--- Generated by EmmyLua(https://github.com/EmmyLua)
--- Created by Zero.
--- DateTime: 2019-05-25 16:53
---

local function proxy_kvo_key(trackKey)
    return ("_kvo_" .. trackKey)
end

local function proxy_addObserverCallbackForKey(proxy, key, callback)
    if not key or not proxy.realTarget then
        return
    end

    local kvokey = proxy_kvo_key(key)
    local callbackFuncs = proxy[kvokey]
    if not callbackFuncs then
        callbackFuncs = {}
        proxy[kvokey] = callbackFuncs
    end
    table.insert(callbackFuncs, callback)
end

--[[
	valueChangeFunc(key, oldValue, newValue)
	http://lua-users.org/wiki/GeneralizedPairsAndIpairs
]]--
function kvo_addForKey(tbl, trackKey, valueChangeFunc)
    if not tbl or type(tbl) ~= "table" then
        assert(NO, "只支持监听table")
        return tbl
    end

    if not trackKey then
        assert(trackKey, "监听的key或者index不能为nil")
    end

    --说明当前的tbl就是proxy
    if tbl.realTarget then
        proxy_addObserverCallbackForKey(tbl, trackKey, valueChangeFunc)
        return tbl
    end

    local proxy = {}

    proxy_addObserverCallbackForKey(proxy, trackKey, valueChangeFunc)

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

            local kvokey = proxy_kvo_key(k)
            if proxy[kvokey] then
                for i, callback in ipairs(proxy[kvokey]) do
                    callback(k, oldValue, v)
                end
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
            local function iter(t, i)
                i = i + 1
                local v = t[i]
                --v = nil时循环结束
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

    proxy.realTarget = tbl

    return proxy
end


function kvo_removeForKey(proxy, key)
    if not key or not proxy then
        return
    end

    local kvokey = proxy_kvo_key(key)
    local callbackFuncs = proxy[kvokey]
    if callbackFuncs then
        local count = #callbackFuncs
        for i = 1, count do
            table.remove(callbackFuncs)
        end
    end
    proxy[kvokey] = nil;
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
newTable.key = "100"
newTable.name = "zero"
newTable[1] = 334
newTable = kvo_addForKey(newTable, "1", function(k, oldV, newV)
	print("第一", k, oldV, newV)
end)
newTable.key = 1123
newTable[1] = "卡卡高可靠"

newTable = kvo_addForKey(newTable, 1, function(k, oldV, newV)
	print("第二", k, oldV, newV)
end)
newTable[1] = "nil"
newTable.key = "ssssss"

kvo_removeForKey(newTable, "1")

newTable[1] = "看看能否监听到"

newTable.key = "价格"


return _class
]]--