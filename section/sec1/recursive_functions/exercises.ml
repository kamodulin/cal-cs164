(******************************************************************************)
(* Recursive functions: exercises *)

(* Exercise: Define the function `sum` that takes in a list of integers and
 * returns its sum.
 *)
let sum lst =
  failwith "TODO"

(* Exercise: Do the same as `sum`, but using tail recursion.
 *)
let sum_tail lst acc =
  failwith "TODO"

(* Exercise: Define the function `takeWhile` that takes in a list of integers, a
 * predicate function `f` and collects the elements until an element that
 * doesn't satify the predicate is reached.
 *
 * For example, given `[1; 2; 3; 4; 5; 3; 2]` and `fun a -> a < 4`, this
 * function would return `[1; 2; 3]`.
 *)
let takeWhile lst f =
  failwith "TODO"

(* Exercise: A faster Fibonacci
 *
 * The problem with the naive Fibonacci function is that it compute subproblems
 * repeatedly. For example, computing `fib 5` requires computing both `fib 3`
 * and `fib 4`, and if those are computed separately, a lot of work (an
 * exponential amount, in fact) is being redone.
 *
 * Create a function fib_fast that requires only a linear amount of work.
 *
 * Hint: write a recursive helper function `h : int -> int -> int -> int`, where
 * `h n pp p` is defined as follows:
 *    h 1 pp p = p, and
 *    h n pp p = h (n-1) p (pp+p) for any n > 1.
 * The idea of h is that it assumes the previous two Fibonacci numbers were `pp`
 * and `p`, then computes forward `n` more numbers. Hence,
 *   fib n = h n 0 1
 * for any n > 0.
 *
 * What is the first value of n for which fib_fast n is negative, indicating
 * that integer overflow occurred?
 *)
let fib_fast : int =
  failwith "TODO"

(* Exercise: function associativity
 *)

(* Which of the following produces an integer, which produces a function, and
 * which produces an error? Decide on an answer, then check your answer in the
 * toplevel.
 *
 *   add 5 1
 *   add 5
 *   (add 5) 1
 *   add (5 1)
 *
 *)
