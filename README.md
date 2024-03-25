This is a toy interpreter for brainfuck (in its very early stage)

# How to run the program
Run
```bash
stack run -- example.bf
```
or
```bash
nix run . -- example.bf
```
to see a "hello world" !

# Implementation
The "endless tape" is implemented with the _zipper_ data structure in mind.
Modifing the _nth_ element of a linked list is expensive. In order to mitigate
this, we can use a _zipper_ implementation of a list, which facilitates
traversal of near elements by expressing the list at a given point. The `Tape`
type is a variant of a zipper list tailored for the brainfuck interpreter, since
it is intentionally made to be not bounded to match the memory model of the
brainfuck language.

# Sources
https://en.wikipedia.org/wiki/Zipper_(data_structure)
https://learnyouahaskell.com/zippers
https://en.wikipedia.org/wiki/Brainfuck

# Credits
Thanks to all those people who helped me along the way, without you this fun
project wouldn't be possible :)

# Have fun
As said, have fun!
