local util = require('util')

local print = print
local open = io.open
local ipairs = ipairs
local pairs = pairs
local table = table
local io = io

module(...)

WordGraph = util.createClass()
Word = util.createClass()

-- A string representation of the word
util.addPropertyAccessFunctions(Word, "string")

-- Words keep an array of characters corresponding to the word
util.addPropertyAccessFunctions(Word, "chars")

-- A flag used to store whether the given word has been visited.
util.addPropertyAccessFunctions(Word, "visited", "isVisited", "setVisited")

-- A flag used to store whether the given word has been visited.
util.addPropertyAccessFunctions(Word, "relatives")

function Word:_initializeInstance(wordString)
    self:setString(wordString)
    self:setChars(util.getCharArray(wordString))
    self:setRelatives({})
    self:setVisited(false)
end

function Word:toString()
    local result =  (self:isVisited() and '+ ' or '- ') .. self:getString() .. ' -> '
    for relatedWord, _ in pairs(self.relatives) do
        result = result .. relatedWord .. ' '
    end
    return result
end

-- Adds the given word as being related to this word and
-- vice-versa
function Word:setRelated(relatedWord)
    self.relatives[relatedWord:getString()] = true
    relatedWord.relatives[self:getString()] = true
end


function WordGraph:_initializeInstance(dictionaryFile)
    -- The possible characters supported by this dictionary
    local alphabet = {}
    local alphaSorted = {}

    -- A graph of the words and their relationships.
    local graph = {}

    -- Iterate over each line in the dictionary...
    for line in dictionaryFile:lines() do

        -- Convert the line to lowercase to ensure that we're comparing apples to apples
        local origLine = line
        line = line:lower()
        --print('Line: ' .. origLine .. ' Lower: ' .. line)

        -- If the word's not already in the graph, add it and assign it an empty table
        if not graph[line] then
            local word = Word:new(line)
            graph[line] = word
            for _, char in ipairs(word:getChars()) do
                alphabet[char] = true
            end
        end
    end

    -- For easier debugging, we'll sort the alphabet.  This makes it easier to verify
    -- debug print statements and the order in which we're trying different combinations.
    for alpha, _ in pairs(alphabet) do
        table.insert(alphaSorted, alpha)
    end
    table.sort(alphaSorted)


    local addRelationIfWordIsValid = function(word, testString)
        local relatedWord = graph[testString]
        if relatedWord ~= nil then
            word:setRelated(relatedWord)
        end
    end

    -- At this point, the graph contains all possible words as keys.  Each word can be
    -- thought of as a node in the graph.  The table corresponding to each node will
    -- tell us the edges from the current node to all related nodes.

    -- Now, we need to populate the relatives tables with all possible combinations.
    for wordString, word in pairs(graph) do

        -- Valid operations for word modifictaions are changing a character, adding a
        -- character, or removing a character.

        -- Let's start with the simple case.  For each character in the word, we'll iterate
        -- over all possible combinations of possible relatives based on changing a character.
        -- io.write('Processing: ')
        -- io.write(wordString)
        -- io.write('\n')
        -- io.flush()
        local chars = word:getChars()
        local numChars = #chars
        for index, char in ipairs(chars) do
            local prefix = (index == 1) and '' or wordString:sub(1, index-1)
            local suffix = (index == numChars) and '' or wordString:sub(index+1)


            -- Try all possible alpha combinations for the current position
            for _, alpha in ipairs(alphaSorted) do
                if (alpha ~= char) then
                    addRelationIfWordIsValid(word, prefix .. alpha .. suffix)
                end
            end

            -- Simply try removing the given character to see whether the resulting
            -- word is valid.
            addRelationIfWordIsValid(word, prefix .. suffix)
        end

        -- Once we're processing a given word, we can clear its chars array.
        word:setChars(nil)
    end

    -- io.write('Alphabet: ')
    -- for _, char in ipairs(alphaSorted) do
    --     io.write(char)
    --     io.write(' ')
    -- end
    -- io.write('\n')
    -- io.flush()

    self.graph = graph
    self.alphaSorted = alphaSorted
    self:print()
end

function WordGraph:print()
    print('Graph: (- not visited, + visited)')
    for _, word in pairs(self.graph) do
        print('  ' .. word:toString())
    end
end

function WordGraph:resetVisitedState()
    for _, word in pairs(self.graph) do
        word:setVisited(false)
    end
end

function WordGraph:getAlphabet()
    return self.alphaSorted
end

function WordGraph:isWordValid(wordString)
    return (wordString ~= nil) and (self.graph[wordString] ~= nil)
end

function WordGraph:depthFirstSearch(stack, curWordString, endWordString)
    local success = false
    local curWord = self.graph[curWordString]

    -- Push the current word on top of the stack and visit it
    print('push: ' .. curWordString)
    stack[#stack + 1] = curWordString
    curWord:setVisited(true)

    if (curWordString == endWordString) then
        success = true
    else
        local curRelatives = curWord:getRelatives()
        if curRelatives[endWordString] ~= nil then
            success = self:depthFirstSearch(stack, endWordString, endWordString)
        else
            -- For each relative of the current word...
            for relatedWordString, _ in pairs(curWord:getRelatives()) do

                local relatedWord = self.graph[relatedWordString]

                -- If the word hasn't been visited, push it on top of the stack and do a depth first search
                if not relatedWord:isVisited() then
                    success = self:depthFirstSearch(stack, relatedWordString, endWordString)
                    if success then
                       break
                    end
                end
            end
        end
    end

    -- If at the current word we weren't able to find any successful traversals to the end node,
    -- we'll pop the current node off the stack.
    if not success then
        print('pop: ' .. stack[#stack])
        stack[#stack] = nil
    end

    return success
end

function WordGraph:getWordChainDepthFirst(startWord, endWord)
    local result = nil
    print('Depth-First Search: ' .. startWord .. ' - ' .. endWord)
    if not self:isWordValid(startWord) then
        print('Invalid startWord: ' .. startWord)
    elseif not self:isWordValid(endWord) then
        print('Invalid endWord: ' .. endWord)
    else
        result = {}
        local success = self:depthFirstSearch(result, startWord, endWord)
        if success then
            print('Found chain!')
            for index, wordString in ipairs(result) do
                if (index > 1) then
                        io.write(' -> ')
                end
                io.write(wordString)
            end
            io.write('\n')
            io.flush()
        else
            print('No chain found :(')
        end
        self:print()

    end

    return result
end

function WordGraph:getWordChainsBreadthFirst(startWord, endWord)
    -- coming soon.
end

