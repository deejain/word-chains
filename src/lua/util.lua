local setmetatable = setmetatable
local string = string
local type = type
local table = table
local pairs = pairs
local ipairs = ipairs
local tostring = tostring
local error = error

module(...)

local DEFAULT_INDENT = '    '

-- A function used as a no-op.
function nilFunction()
    -- nothing to do.
end

-- A singleton corresponding to the Null Object design pattern.  When this object is indexed,
-- it will always return the nilFunction.  Therefore, this object can be substituted for any
-- object, as long as only functions are invoked within the given instance.
NilObject = {}
setmetatable(NilObject, {__index = function() return nilFunction end})

-- Creates a new class that inherits from the given base class.  When defining a base class, pass nil as the baseClass argument.
-- To create an abstract class, pass true as the isAbstract argument.  In non-abstract classes, the newly created class will
-- have a new() function for creating new instances.  When this fucntion is invoked, it will automatically call any _initializeInstance()
-- function defined within the given class.
function createClass(baseClass, isAbstract)
    local newClass = {}
    local newClassMeta = {__index = newClass}

    if not isAbstract then
        function newClass:new(...)
            return self:newFromTable(nil, ...)
        end

        function newClass:newFromTable(newInstance, ...)
            local initFromTable = (newInstance ~= nil)
            newInstance = newInstance and newInstance or {}
            setmetatable(newInstance, newClassMeta)

            if newClass._initializeInstance then
                newClass._initializeInstance(newInstance, initFromTable, ...)

            elseif baseClass and baseClass._initializeInstance then
                baseClass._initializeInstance(newInstance, initFromTable, ...)
            end

            return newInstance
        end
    end

    if baseClass then
        setmetatable(newClass, {__index = baseClass})
    end

    return newClass
end

-- This function adds getter and setter fucntions to the given class, for the given variable.
-- For example, if one calls addPropertyAccessFunctions(MyClass, foo), the following functions
-- will be defined for MyClass.
--    - MyClass:getFoo()
--    - MyClass:setFoo(value)
-- The user can optionally specify custom getter and/or setter names.
function addPropertyAccessFunctions(class, variableName, getterName, setterName)
    if not (getterName and setterName) then
        local upperVariableName = variableName:sub(1, 1):upper() .. variableName:sub(2)
        getterName = getterName and getterName or ('get' .. upperVariableName)
        setterName = setterName and setterName or ('set' .. upperVariableName)
    end

    class[getterName] = function(self)
        return self[variableName]
    end

    class[setterName] = function(self, value)
        self[variableName] = value
    end
end

function printTable(file, t, indent, keys, printTrailingComma, appendTable)
    local containsNonIndexKeys
    if not keys then
        keys = {}
        for k, v in pairs(t) do
            keys[#keys + 1] = k
            if (not containsNonIndexKeys) and (type(k) ~= 'number') then
                containsNonIndexKeys = true
            end
        end
        table.sort(keys)
    end

    local originalIndent = indent
    indent = indent and (indent .. DEFAULT_INDENT) or DEFAULT_INDENT

    if not appendTable then
        file:write('{')
        if containsNonIndexKeys then
            file:write('\n')
        end
    end

    local tableNonEmpty = #keys > 0
    local multiline = containsNonIndexKeys
    local valueSeparator = containsNonIndexKeys and ',\n' or ','
    for index, k in ipairs(keys) do
        local v = t[k]
        if multiline then
            file:write(indent)
        end
        local kType = type(k)
        if kType == 'string' then
            file:write('[\'' .. k .. '\'] = ')
        elseif kType ~= 'number' then
            error('Unsupported key type: ' .. tostring(kType) .. ' for key: ' .. tostring(k))
        end

        local curValueSeparator = (index == #keys) and (multiline and valueSeparator or '') or valueSeparator
        local vType = type(v)
        if vType == 'string' then
            file:write('\'' .. v .. '\'' .. curValueSeparator)
        elseif (vType == 'boolean') or (vType == 'number') then
            file:write(tostring(v) .. curValueSeparator)
        elseif (vType == 'table') then
            printTable(file, v, indent, nil, true)
        else
            error('Unsupported value type: ' .. tostring(vType) .. ' for value: ' .. tostring(v))
        end
    end

    if originalIndent and tableNonEmpty and containsNonIndexKeys then
        file:write(originalIndent)
    end

    if not appendTable then
        if printTrailingComma then
            file:write('},\n')
        else
            file:write('}\n')
        end
    end
end

function stringEndsWith(str, endStr)
    return (endStr == '') or (string.sub(str, -string.len(endStr)) == endStr)
end

-- This function generates a char array from each character of the given string.  The string can
-- contain a mix of ASCII and Unicode characters.   In the resulting array, each entry will contain
-- a string containig representing the character at the matching index in the given string.
function getCharArray(str)
    local result = {}
    for char in str.gmatch(str, '([%z\1-\127\194-\244][\128-\191]*)') do
        result[#result + 1] = char
    end

    return result
end


function replaceCharInString(str, pos, char)
    return str:sub(1, pos-1) .. char .. str:sub(pos+1)
end
