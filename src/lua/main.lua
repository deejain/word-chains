local util = require('util')
local wordGraphModule = require('wordgraph')

local DEFAULT_DICTIONARY = '/usr/share/dict/words'

function main(dictionary)
    dictionary = dictionary and dictionary or DEFAULT_DICTIONARY

    print('Loading: ' .. dictionary)
    local dictionaryFile = io.open(dictionary, 'r')
    if (not dictionaryFile) then
        print('ERROR: Unable open dictionary.')
    else
        local graph = wordGraphModule.WordGraph:new(dictionaryFile)

        graph:getWordChainDepthFirst('aaa', 'dddd')
        dictionaryFile:close()
    end
end

main(...)