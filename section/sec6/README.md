# Section 6: How do you refer to the heap?

## Introduction

References are a simple way to add mutable data to functional programming
languages. A reference is a pointer to a single location in memory whose value
can change as the program executes. Intuitively, we can think of a reference as
a "box" or "cell" that contains a mutable value.

⚠️ **Note:** Mutation should be used sparingly in functional programs. As we've
discussed, OCaml makes all variables immutable by default, requiring the use of
`ref` to mark data as mutable. Can you think of some reasons why mutation might
make programs difficult to reason about?

## Goals

We'll add support for the following operations:

- `(ref e)` — creates a reference with the initial value `e`.
- `(deref r)` — gets the value from a reference. If the expression `r` that we
  are trying to dereference is  not a reference, raise an exception that you
  define.
- `(set-ref r e)` — sets the value of the reference `r` to `e` and also evaluate
  to `e`. If the expression `r` that we are trying to update is not a reference,
  raise an exception that you define.

References should be displayed by the interpreter and runtime as `(ref e)`,
where `e` is the representation of the currently stored value.

## Starting code

We'll build off the starter code from `hw3`. The only additions we've made to
the runtime are heap support and an error function that you can call using
`extern` in your compiled assembly.

For a refresher on the heap, have a look at
[the lecture notes on pairs and the heap](https://inst.eecs.berkeley.edu/~cs164/fa23/notes/11-Pairs.html).

For a refersher on error handling and the runtime, have a look at the
[lecture notes on error handling](https://inst.eecs.berkeley.edu/~cs164/fa23/notes/12-Handling-Errors.html).

Lastly, we also added support for `do` blocks to simplify testing for this
section. More on this below!

## 1. Testing and using `do` blocks (1 subtask)

To make testing mutable data easier, we've implemented a common lisp construct
in the interpreter and compiler: `do` blocks. `do` blocks take in a sequence of
expressions (at least 1), execute each of them in order, and evaluate to
whatever the last expression evaluates to. For instance,

```lisp
(let ((r (ref 1)))
  (do (set-ref r 2)
      (deref r)))
```

should evaluate to `2`.

**Task 1.1**: Write tests for `(ref e)`, `(deref r)`, and `(set-ref r e)`. Try
using `do` blocks to combine calls to `(ref e)`, `(deref r)`, and
`(set-ref r e)` in more complicated test cases.

## 2. Adding references to the interpreter (3 subtasks)

Let's start off by implementing references in our interpreter using OCaml's
built-in `ref` data structure. OCaml references were covered in the
[lecture on conditionals](https://inst.eecs.berkeley.edu/~cs164/fa23/notes/06-Conditionals.html).
You might also want to pull up the
[chapter on references from the "Functional Programming with OCaml" book](https://www.cs.cornell.edu/courses/cs3110/2019sp/textbook/ads/refs.html).

We have already added the `Ref` constructor to the `value` type in `interp.ml`.

**Task 2.1**: Add support for `(ref e)` to the interpreter.

**Task 2.2**: Add support for `(deref r)` to the interpreter.

**Task 2.3**: Add support for `(set-ref r e)` to the interpreter.

## 3. Adding references to the compiler (4 subtasks)

The compiler should put references on the heap and use `0b001` as the tag for
runtime reference values. Before we get into implementing references in
`compile.ml`, let's update the runtime to properly identify and print values
that are references.

**Task 3.1**: Update `runtime.c` to include a `ref_tag` and `ref_mask`, check
for the `ref_tag` in `print_value`, and handle printing of references. Also
remember to add the `ref_tag` and `ref_mask` to `compile.ml`!

From the compiler's perspective, a reference is just a pointer to a heap address
with the `0b001` type tag. All our heap addresses will be 8-byte aligned,
meaning that their three least significant bits will always be zero.
Additionally, all our values are 8 bytes (64 bits) in size. In order to place a
value on the heap, you need to store it at the address pointed to by the `Rdi`
register and then increment the `Rdi` register by 8. We currently only support
**allocation** (not deallocation) on the heap, so you do not need to worry about
freeing the memory.  Remember that while our stack grows towards lower
addresses, our heap grows towards higher addresses.

**Task 3.2**: Add support for `(ref e)` to the compiler. If you're feeling a bit
stuck, take a look at how we implement pairs in
[the class compiler](https://github.com/berkeley-cs164-2023/class-compiler-f23).

**Task 3.3**: Add support for `(deref r)` to the compiler. As part of your
implementation, define a function `ensure_reference` to verify that the value
you are dereferencing is in fact a reference. If you're feeling a bit stuck,
take a look at how we implement `left` and `right` on pairs in
[the class compiler](https://github.com/berkeley-cs164-2023/class-compiler-f23).

**Task 3.4**: Add support for `(set-ref r e)` to the compiler.
