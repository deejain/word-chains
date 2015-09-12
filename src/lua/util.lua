local setmetatable = setmetatable

module(...)

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
            local newInstance = {}
            setmetatable(newInstance, newClassMeta)

            if newClass._initializeInstance then
                newClass._initializeInstance(newInstance, ...)

            elseif baseClass and baseClass._initializeInstance then
                baseClass._initializeInstance(newInstance, ...)
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
