local util = require('util')
local wordGraphModule = require('wordgraph')

local DEFAULT_DICTIONARY = '../../data/test-words.txt'

function usage()
    print('')
    print('Supported Operations:')
    print('  alpha - Print the alphabet supported by the dictionary')
    print('  bfs START_WORD END_WORD - Breadth-first search of the graph')
    print('                            END_WORD using single character modifications')
    print('  dfs START_WORD END_WORD - Depth-first search of the graph for a word chain')
    print('                            between the start and end words')
    print('  list - Print adjacency list corresponding to the currently loaded word graph')
    print('  help - Print this help message')
    print('  quit - Exit the program')
end

function printResult(result, executionTime)
    if result and #result > 0 then
        print('Chain Found!  Time ' .. executionTime .. ' sec')
        for index, wordString in ipairs(result) do
            if (index > 1) then
                    io.write(' . ')
            end
            io.write(wordString)
        end
        io.write('\n')
        io.flush()
    else
        print('No chain found :(  Time ' .. executionTime .. ' sec')
    end
end

function main(dictionary)
    dictionary = dictionary and dictionary or DEFAULT_DICTIONARY

    print('')
    print('---------------------------------------')
    print('--           WORD CHAINS             --')
    print('---------------------------------------')
    print('')

    local startTime = os.time()
    print('Dictionary: ' .. dictionary)
    local graph = wordGraphModule.WordGraph:new(dictionary)
    print('Graph ready. Time ' .. os.time() - startTime .. ' sec')

    usage()
    local command
    while(true) do
        io.write('\nPlease enter a command: ')
        io.flush()
        command = io.read()
        if command == 'quit' then
            break
        elseif command == 'help' then
            usage()
        elseif command == 'list' then
            graph:print()
        elseif command == 'alpha' then
             io.write('Alphabet: ')
             for _, char in ipairs(graph:getAlphabet()) do
                 io.write(char)
                 io.write(' ')
             end
             io.write('\n')
             io.flush()
        else
            local words = {}
            for word in command:gmatch("%w+") do
                table.insert(words, word)
            end
            if (words[1] == 'dfs') or (words[1] == 'bfs') then
                local startWord = words[2]
                local endWord = words[3]
                local valid = true
                if not graph:isWordValid(startWord) then
                    print('Invalid startWord: ' .. startWord)
                    valid = false
                end
                if not graph:isWordValid(endWord) then
                    print('Invalid endWord: ' .. endWord)
                    valid = false
                end

                if valid then
                    local searchName
                    local searchFunctionName
                    if (words[1] == 'dfs') then
                        searchName = 'Depth-frist'
                        searchFunctionName = 'getWordChainDepthFirst'
                    else
                        searchName = 'Breadth-frist'
                        searchFunctionName = 'getWordChainBreadthFirst'
                    end
                    print('\n' .. searchName .. ' search: ' .. startWord .. ' - ' .. endWord)
                    startTime = os.time()
                    local result = graph[searchFunctionName](graph, startWord, endWord)
                    printResult(result, os.time() - startTime)
                end
            else
                print('Unknown command: ' .. command)
            end
        end
    end
end

main(...)