---
--- Generated by EmmyLua(https://github.com/EmmyLua)
--- Created by momo.
--- DateTime: 2019-07-01 12:57
---


----------------------------------------------------
--- table
----------------------------------------------------

--- map字典
---@param t table
---@param fn function func(k, v)
---@return table
function table.map(t, fn)
    for k, v in pairs(t) do
        t[k] = fn(k, v)
    end
    return t
end

--- 过滤table字典中的数据
---@param t table
---@param fn function func(k, v)
---@return table
function table.filter(t, fn)
    for k, v in pairs(t) do
        if not fn(k, v) then
            t[k] = nil
        end
    end
    return t
end


----------------------------------------------------
--- string
----------------------------------------------------

--- 以指定字符把字符串拆分成字符串数组
---@param text string
---@param separateString string
---@return table
function string.split(text, separateString)
    if not separateString then
        return { text }
    end

    local patten = "[^" .. separateString .. "]+"
    local words = {}
    for s in string.gmatch(text, patten) do
        table.insert(words, s)
    end
    return words
end

