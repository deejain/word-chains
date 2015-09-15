# Word Chains
This repository contains a solution for the word chains problem.

# Problem
Write a program that given two (valid) words, can find a chain of (valid) intermediate words, wherein each word in the chain differs in only one letter from its neighbors.  Assume words are available in a dictionary (you can make your own for testing purposes, if you like).  You may choose your own start and end words.

# Solution
The problem was solved by generating an adjacency list from the given dictionary.  The list was stored in a hashtable, where the word was used a key and a list of all possible related words were stored as the value.  To determine a given word chain, the user can use either breadth-first search or depth-first search.

Depth-first search will any path from the start word to the end word, if one exists.  However, breadth-first search will find the shortest path betwene the two words, if such a path exists.

Here's a detailed breakdown of the solution.

**Dictionary Loading**
1. Load the dictionary into memory -- a hashtable.  While doing this, you can determine the alphabet of the given dictioanry by looking at each character of each word and adding it to a given hashtable.  This has O(C) computation and space complexity, where C is the total number of characters in the dictioanry.
2. For each word in the dictionary, go through each character and remove the character and test whether the resulting string results in a valid word.  If it does, flag the current word as being related to this shorter word, and vice-versa.
3. For each word in the dictionary, go through each character and change the character to any of the characters in the alphabet to see if it results in a valid word.  If it does, flag the current word and  being related to the composed word, and vice-versa.

Steps 2 and 3 can be done in the same loop that goes through each word in the dictionary and each character within each word.  They have time complexity of O(C * Alphabet_size), where C is the total number of characters in the dictionary.  Note that since the alphabet size is a constant, the time complexity is O(C).

**Searching**
The searching algorithms are fairly standard.  So, they will not be discussed in detail here.  Please see ./src/lua/wordgraph.lua for the implementation of the searches.

Both breadth-first and depth-first searches have O(W + R) worst case performance, where W is the total number of words and R is the total number of relationships between the words.   Since we use an adjacency list to store the graph, the space complexity is also O(W + R).


## Language
Lua was used to code the solution, since it's a light-weight language that provides easy string manipulation functions.

## Assumptions
1. Valid operations on words are: adding a character, removing a character, or changing a character.  After applying any one of these operations, the resulting word (if still part of the dictionary) is considered to differ only by one from the original word.
2. Alhpabet of the dictaionry is not given, but it can be derived from the dictionary itself.


## Operation

### Supported Platforms
OS X and Linux/Ubuntu

### Pre-requisites
In order to run this solution, you must have the following installed on your machine.
- Git
- Lua

If you need those tools, perform the following steps.
1. Install Homebrew - http://brew.sh
2. In a Terminal window, run 'brew install git lua'

Next, you can obtain the solution using the following command.
```
git clone git@github.com:deejain/word-chains.git
```

### Building
1. Open a Terminal window and _cd_ into the word-chains repo
2. Run 'make'

Upon completion of the build, the ./output/generated folder will contain adjacency lists corresponding to the *.txt dictionaries under the ./data folder.  These auto-generated files are optimized to minimize disk space.  One can find human-readable versions of these files under ./output/generated-readable

### Execution
Run the following commands in a Terminal window.  Then, follow on-screen instructions.
```
// Go into the Lua directory
cd ./src/lua/

// Run
lua ./main.lua <dictionary_file>

// Available dictionary files are:
../../data/test-words.txt - A raw text file contain a few contrived words for testing.
../../data/words.txt - A raw text file containing a copy of the /usr/share/dict/words
                       file from OS X.  Note that this a fairly large file with
                       ~236,000 words.
../../output/generated/test-words.lua - The Lua adjacency list corresponding to the
                                         ../../data/test-words.txt dictionary.
../../output/generated/words.lua - The Lua adjacency list corresponding to the
                                   ../../data/words.txt dictionary.
```

## Performance

### Dictionary Loading
Loading the raw dictionaries and building the adjacency list at runtime is fairly expensive.  For example, loading words.txt takes approximately 90 seconds.  We could shorten this down to about 60 seconds, if we used LuaJIT to compile our Lua file.  However, 60 seconds still isn't that great.

Rather than paying the cost of generating an adjacency list at runtime, if we use the adjacency list generated by the build, we cut down the dictionary load time to about 2 seconds.  That's a 98% reduction in loading time :)

Of course, the reduction in loading time isn't free.  When we compare the size of words.txt against that of words.lua, we see that the size increases from 2.5 MB to 7.4 MB.  That's about a 3x increase in file size, which isn't too bad of a compromise, considering that file system space is generally cheaper than computational time.

### Searching
The breadth-first search takes longer to execute on average because it has to go through all vertices at any given distance form the start node before it can move out further.  On the other hand, depth-first search completes faster because it keeps traversing further from the start node until it finds the desired node or can no longer travers any further.

Note that the two search algorithms are independent of how the dictionary is loaded.

## Future Consideration
- It would be good to add in unit tests for verifying the functions written
- It would be worthwhile to explore using LuaJIT to run the solution.  LuaJIT does impose a limit on the number of constants (strings in this case) of 65,536.  Therefore, to compile the words.lua dictionary using LuaJIT, one would have to break-up the dictionary into smaller chunks.  Also, note that LuaJIT has a smaller stack size limit than the host platform.  Therefore, the recursion used in the depth-first search algorithm would have to either be modified to not use recursion or the LuaJIT stack size would have to be increased.
- Adjacency list generation should be updated to ensure that the file minimizing approach can properly handle symbols and other non-alphabet characters.