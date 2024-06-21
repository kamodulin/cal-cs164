# Section 3: Compiler Infrastructure and Testing

Welcome to your third discussion section of CS 164!

Section is not graded in any way—it is meant to solidify your understanding of
the concepts discussed in lecture, and provide you additional practice with the
concepts necessary to complete your homework.

### Goals

The goal of this section is to prepare you for the infrastructure of Homework 2
and the homeworks thereafter. Specifically, this section will cover:

- The typical directory layout for homeworks going forward.
- The differential tester and writing good test examples.
- The compiler runtime.
- (Bonus) Running the interpreter and compiler manually.

## 1. Directory layout (0 subtasks)

These are the directories you'll need to modify in this section and in homework
assignments:

- **[examples/](./examples)**: Interpreter and compiler examples. You will add
  test cases here every time you implement a new language feature.
- **[lib/](./lib)**: The interpreter and compiler implementation. Typically,
  you will modify both [lib/interp.ml](./lib/interp.ml) and
  [lib/compile.ml](./lib/compile.ml) in each homework. Sometimes you will also
  need to modify [lib/runtime/runtime.c](./lib/runtime/runtime.c), which
  defines the runtime for our language.

These are the directories we provide for you that you won't need to modify (feel
free to take a look, though!):

- **[asm/](./asm)**: A library for producing assembly programs.
- **[s_exp/](./s_exp)**: A library for working with S-expressions.
- **[test/](./test)**: A library for differentially testing your interpreter
  and compiler (explained in the next section).
- **[bin/](./bin)**: The "main" functions for the interpreter and compiler.

## 2. Writing differential tests (1 subtask)

*Differential testing* is a form of software testing in which you:

1. Execute different implementations of the same  functionality (e.g., GCC and
   LLVM) with the same inputs.
2. Compare their outputs.
3. Report any anomalies as bugs.

(Definition courtesy of [Mayur Naik's slides](https://www.cis.upenn.edu/~mhnaik/edu/cis700/lessons/differential_testing.pdf).)

For this class, you'll be writing compilers and interpreters side-by-side, and
they should agree on all possible inputs---so differential testing is a perfect
fit!

In fact, for most of the remaining homeworks for this class, we will provide you
with a `test` library that performs differential testing of your interpreter and
compiler. You can run all your tests that you create using this library with the
following command:

```sh
dune runtest -f
```

Speaking of using this library, there are three main ways to do so!

### Option 1: Testing the interpreter and compiler against an output

When you want to test if the result of a program (e.g. `(add1 41)`) is as
expected (e.g. `42`), you should:

- Write a program in the language you are implementing in a file with extension
  `.lisp` in the `examples/` directory (e.g. `examples/test42.lisp`).
- Write the expected output in a file with the same name as the `.lisp` file but
  with a `.out` extension in the `examples` directory (e.g.
  `examples/test42.out`).

### Option 2: Testing the interpreter and compiler on buggy programs

Some programs are expected to result in an error instead of a value. For
example, `(add2 40)` should result in an error because `add2` is not a valid
primitive. To test this behavior, you can use a `.err` file instead of a `.out`
one. The content of `.err` files are only used to print out failing test cases,
so you can add whatever description you'd like there.

### Option 3: Purely differential interpreter and compiler testing

When you want to test __only__ if the interpreter and the compiler agree on the
result of a program, you may leave out the `.out` file.

**Task 2.1:** Take a look at `lib/interp.ml` and/or `lib/compile.ml` to see what
language the interpreter and compiler support. Write three different tests for
the interpreter and compiler, each using a different mechanism of the three
listed above provided by the `test` library.

### A shorthand

As a convenience, you can also provide a file `examples/examples.csv` of the
following format:
```
input program 0, expected output 0
input program 1, expected output 1
... etc
```
By using the convenience file `examples/examples.csv`, you can write multiple
input-output tests all in one file that correspond to Option 1 above.

If you omit the "expected output" column for a row, the testing framework will
perform a purely differential test, which corresponds to Option 3 above.

Note that the `examples/examples.csv` shorthand does not support any equivalent
of `.err` files (Option 2 above), so you cannot use this shorthand to check
that your interpreter and compiler both throw an exception.

## 3. Working with the compiler runtime (3 subtasks)

Updating the compiler typically involves modifying
[lib/compile.ml](./lib/compile.ml).
If you introduce a new _kind_ of data, you will also need to modify
[lib/runtime/runtime.c](./lib/runtime/runtime.c)
because, for example, `print_value` needs to know how to print the new data.

_Hint:_ For more information about the compiler runtime, check out the
[first set of lecture notes](https://inst.eecs.berkeley.edu/~cs164/fa23/notes/00-What-Is-A-Compiler.html)!

_Note:_ It's strongly recommended to write tests before modifying the
compiler, interpreter, or runtime, so you can be more sure that any changes you
make do not result in any unintentional consequences.

**Task 3.1:** Change the compiler such that both booleans and numbers use 1 bit for
tagging. Booleans should be tagged with `0` and numbers with `1`.

**Task 3.2:** Change the interpreter and the compiler such that the boolean `true`
is printed as `#t` and the boolean `false` is printed as `#f`

**Task 3.3:** Implement `bool?`, which returns `true` if its argument is a boolean,
and `false` otherwise.

## 4. Bonus: Running the interpreter and compiler manually (2 subtasks)

_Note:_ Strictly speaking, you don't need to use any of the commands in this
section. Most of the time, you'll just want to use `dune runtest -f` as
described above!

Suppose there is a file `program.lisp` that contains the following code:

```scheme
(add1 41)
```

To run the interpreter on this file, run the following command:

```sh
dune exec -- bin/interp.exe program.lisp 
```

To run the compiler on this program, run the following command:

```sh
dune exec -- bin/compile.exe program.lisp ./out/
```

There will then be two files in `out/`:

- `program.lisp.exe`: The executable.
- `program.lisp.s`: The assembly of `program.lisp`. You may want to read this
  file when debugging.

You can run the executable (i.e., the compiled code) with the following command:
```sh
./out/program.lisp.exe 
```

**Task 4.1:** Interpret the 3 testing programs that you just wrote.

**Task 4.2:** Compile and run the 3 testing programs that you just wrote.
