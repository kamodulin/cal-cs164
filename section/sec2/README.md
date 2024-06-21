# Section 2: Testing

Welcome to your second discussion section of CS 164!

Section is not graded in any way—it is meant to solidify your understanding
of the concepts discussed in lecture, and provide you additional practice with
the concepts necessary to complete your homework.

## Background

A *software specification* (a.k.a. "spec") is a description of how a piece of
software should operate. Sometimes, the spec is mathematical and formal; more
often, however, the spec is written in a natural language like English and may
leave room for some ambiguities. The spec for your homework falls into the
latter category.

*Software testing* is a broad area of practice (and active research!) to
eliminate unintentional behavior in code; in other words, to give confidence
that a given program does what it is supposed to do (*satisfies* a given spec).
There are many different ways to test software, but in this class, we will
focus on one popular style of tests: unit testing.

A *unit test* is a test that checks whether a small unit of your code is working
as intended. For example, in OCaml, we might unit test at the level of
individual functions, checking to make sure each one satisfies the specification
we have for it. Unit tests might be contrasted with *integration tests*, whose
purpose are to ensure that the various units of software work *together* as
intended.

Unit tests often cannot *guarantee* that code satisfies a particular
specification, but they can provide us with *increased confidence* that it does
so. In general, the more we test our code, the higher level of confidence we'll
have that our code satisfies our specification. However, there are diminishing
returns: for a small function, 1 test is significantly better than 0 tests, but
200 tests will probably just be a burden to maintain and write.

## A closer look at unit tests

In the simplest formulation, a unit test is a function that:

1. Tests out some piece of code we have written, and
2. Returns `true` if the code works as intended in the tested scenario, and
   `false` otherwise.

Because `true` and `false` are not super informative outputs (i.e., they will
tell us _that_ a test failed, but not _why_), most unit testing frameworks will
opt for slightly fancier return types. The OCaml library we will use has
`assert` functions that return `()` on success and raise an informative
exception on failure.

As for the _input_ of a unit test: in the simplest formulation, we simply take
as input `()`. The OCaml library we will use has unit tests take in values
of type `test_ctxt`, which includes some testing configuration that we can
ignore.

So, in summary, we can conceptually view a unit test as a function of type
```ocaml
unit -> bool
```
but, in the actual framework that we will use, unit tests will have type
```ocaml
test_ctxt -> unit
```
and raise an exception on failure. Note that `unit` is a type in OCaml that
conceptually has nothing to do with unit testing: it is just the type of the
empty tuple `()`.

## Unit testing in OCaml with `OUnit2`

In this class, we will use the library
[`OUnit2`](https://gildor478.github.io/ounit/ounit2/index.html) (among other
tools) to unit test our code.

In addition to writing functions of type `test_ctxt -> unit` for our unit tests,
we also need to tell `OUnit2` *which* such functions to actually run. This is
done via the `run_test_tt_main` function.

The syntax that `OUnit2` uses for the argument to this function is,
unfortunately, rather idiosyncratic. The library defines a custom operator `>::`
that labels unit tests of type `test_ctxt -> unit` with a name for ease of
viewing in the command line. The library also defines a custom operator `>:::`
that labels a _list_ of these labeled unit tests with another label; you can
think of this labeled list of labeled unit tests as a "test suite". The
`run_test_tt_main` function takes in one of these suites and runs it, prints the
output to the console, and returns `()`.

In summary, we define unit tests with `test_ctxt -> unit` functions, label them
with `>::`, group them into a normal OCaml list, label that list with an overall
overall test suite name using `>:::`, then pass the resulting suite to the main
runner function, `run_test_tt_main`. You can see all of this in action in the
file `demo/test.ml`.

## Using `dune` to run our unit tests

All the aforementioned testing functions should go in their own file (usually
named some variation of `test.ml`), which we can run with `dune`. For this
course, we've set up the directory structure so that you can run `dune runtest`
to run the `test.ml` files; if you're curious, you can take a look at how the
`dune` files in each subdirectory of the code we provide for you are set up, but
you will **not** be required to write any `dune` files yourself for this course.

## Live demo!

For this live demo, we will test a piece of code together that finds a path to
a maximum element in a binary tree whose nodes contain non-negative integers
and whose leaves are worth 0. The implementation for this function is in
`demo/tree.ml`, and we will test it in the file `demo/test.ml`.

As we write these tests together, ask yourself: what makes a good unit test?

## Group work!

**Task 1:** You will now break into small groups to write tests for the
`List.sort` found in OCaml's standard library. Please write your tests in the
file `groups/test.ml` and use the function `sort : int list -> int list` that
we define as `List.sort Int.compare` in `groups/test.ml`.

We request that you please do **NOT** yet look at the file `groups/buggy.ml` or
use any functions contained in it.

## Group work, part 2!

When the instructor indicates to do so, please redefine `sort` in
`groups/test.ml` to be `Buggy.sort`, a buggy implementation of
[Quicksort](https://www.youtube.com/watch?v=ywWBy6J5gz8)
that we wrote.

**Question:** How many of your tests now fail? If that number is zero, what
might that mean?

**Task 2:** Look at the tests that fail without opening `Buggy.sort`.
What do they tell you about the implementation of `Buggy.sort`? In what
circumstances does it seem to behave incorrectly? Make hypotheses about what
is wrong with `Buggy.sort`.

**Task 3:** Open `groups/buggy.ml` and make any changes to the code that should
fix it according to the hypotheses that you came up with in the previous task.
Re-run the tests to see if your fixes worked!

**Task 4:** Take a second look at the implementation of `Buggy.sort`. Do you
notice any bugs that your tests didn't catch? If so, add some tests to
`group/test.ml` that capture this behavior. (They should succeed for `List.sort`
but fail for `Buggy.sort`.)
