# Section 13: Implementing an AST-Traversing Screen Reader

In this section we'll be implementing an underlying algorithm for navigating programs in our language using a screen reader, a vital assitive tool for visually-impaired (and non-visually-impaired!) programmers. As computer scientists, it's important that we do our best to make sure everyone can use and contribute to the tools and languages we make. We'll be exploring one way of applying ideas from this course to do that. 

We'll be working from **Schanzer, E., Bahram, S., and Krishnamurthi, S. Accessible ast-based programming for visually-impaired programmers. SIGCSE '19**. In their words:

> "Given a parser that meets certain specifications, this toolkit will...communicate the structure of a program using spoken descriptions, and allow for navigation using standard (accessible) keyboard shortcuts."

## Getting started

We'll be building a command-line program which allows us to navigate the AST of an input program, at each step outputting an English-language description of the currently selected AST node. While we won't implement the audio portion, we will be generating the descriptions which would be utilized in a screen-reader application.

For example, for this program in our Lisp-like language like:

```lisp
(define (f x y) (+ x y))
```

traversing the AST should produce the following output:

```sh
f: a function definition with 2 arguments: x and y # At the root of the AST.
f # Annoucing the function name.
2 arguments: x and y # Announcing the function arguments.
```

Why do we want something like this? As Schanzer et al. explain, programmers rely all the time on visual cues in IDEs (e.g., syntax highlighting, auto-indentation, bracket matching) to interpret code, but many of these cues aren't useful for visually-impared programmers. Can we imagine a programming system that can bring the same benefits through non-visual interface features? And if so, what factors should contribute to its design? Here's how Schanzer et al. set up their design requirements:

> 1. It should not be tied to any one programming language. The editor should be flexible enough to work with different languages (assuming they can satisfy the parser constraints).
> 2. It should be easy to integrate into existing cloud-based editing environments. The editor should not require any browser plugins or extra programs to be installed, and should not require any server-side processing.
> 3. It should communicate structure. The structure of code should be navigable via keyboard, announcing relevant information via a screen reader.
> 4. It should describe code, instead of reading syntax.
> 5. It should be performant. The tool should be responsive and memory-efficient enough to run on tablets, underpowered laptops, etc.

### Question 1: Which design requirements could we fulfill by using the AST to navigate code? Why would the AST fulfill these requirements?

## Implementation

To get the CLI up and running, first open `utop`.

```sh
dune utop
```

Then, inside utop:

```sh
open Cs164.Screenreader;;
navigate "(define (f x y) (+ x y)) (define (g x) (f x x)) (print (f 4 5))";;
```

You're now set up! However, you'll need to complete Tasks 1 and 2 to figure out how to actually traverse the AST with the keyboard and announce each node.

### Task 1: Completing the `read_position` function

You'll be implementing a function which, given a path to an AST node, returns an English-language description of that node. 

We've written code to handle the input and tree searching for you, so all you need to do is fill in the function `read_position`. This function takes in our list of definitions, `defns`, the body of our program, `body`, and the path of keyboard commands `path`, which is a `directions list`. The function returns an English-language description of that AST node as a string. (Hint: To interpolate values in a string in OCaml—such as the name of a `defn`—use `Printf.sprintf`.)

#### Task 2: Understanding `get_coordinates` and `navigate`

`get_coordinates` converts our list of directions, `path`, into an (n, d) tuple which describes the path to the AST node. For example, for this program:

```lisp
(define (f x y) (+ x y))
```

we expect our function definition at the top-level to have coordinates (0, 0), the function name to have coordinates (0, 1), the function arguments to have coordinates (0, 2), etc. From a user's perspective, the output might look like:

```sh
Coordinates: (0,0)
f: a function definition with 2 arguments: x and y  
# User navigates down one node.
Coordinates: (0,1)  
f  
# User navigates down one node.
Coordinates: (0,2)  
2 arguments: x and y  
# User navigates down one node.
Coordinates: (0,3)  
x
```

The `navigate` function takes in user input from stdin and converts it to the `path` that is passed to `get_coordinates`.

Take a look at the implementation of these two functions and see if—from reading the code alone—you can figure out how to traverse the AST using the keyboard!

## Discussion

1. How might we extend this system? What other kinds of AST nodes might we want to build support for? How about in a language like C++ or JavaScript?

2. When building programming tools (and tools in general!), it's always important to really understand the people you're designing for. The paper we're referencing included a lengthy motivation on why a tool like this might be valuable to visually-impaired programmers, and importantly also included a blind researcher. Consider this paragraph from the paper:

> Blind programmers are comfortable hearing the syntax of their preferred language(s) spoken aloud, and typically have their speech settings turned up to several hundred words per minute (one of this paper’s authors, who is blind, listens at well over 750wpm!). Programmers who can parse Java syntax into ASTs in their heads at hundreds of words per minute will mask the effects of a tool designed to communicate AST information."

In this case, the audience you're designing for might have both skills and needs you don't have, which is a challenge for a designer! What implications might this have for what requirements a programming tool should fulfill, how you might go about designing something, and how you would test it? 

(One way to build things for people unlike yourself (which is pretty much everyone!) is to build things *with* the people you intend to be users. In Human-Computer Interaction research, this is called *Co-Design* or *Participatory Design*. There are a *lot* of different ways to do this though! Check out [this paper](https://faculty.washington.edu/ajko/papers/Myers2016ProgrammersAreUsers.pdf) if you're curious!)

3. What kinds of tools do you rely on when you program? What kinds of tools do you think would help make programming easier? How would you go about designing something? 

