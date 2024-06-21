open Asm.Directive
open S_exp

(** constants used for tagging values at runtime *)
let num_shift = 2

let num_mask = 0b11

let num_tag = 0b00

let bool_shift = 7

let bool_mask = 0b1111111

let bool_tag = 0b0011111

(** [operand_of_num x] returns the runtime representation of the number [x] as an
   operand for instructions *)
let operand_of_num (x : int) : operand = Imm ((x lsl num_shift) lor num_tag)

(** [operand_of_bool b] returns the runtime representation of the boolean [b] as an
   operand for instructions *)
let operand_of_bool (b : bool) : operand =
  Imm (((if b then 1 else 0) lsl bool_shift) lor bool_tag)

(* Instructions to convert the ZF flag to the runtime representation of a boolean *)
let zf_to_bool =
  [ Mov (Reg Rax, Imm 0)
  ; Setz (Reg Rax)
  ; Shl (Reg Rax, Imm bool_shift)
  ; Or (Reg Rax, Imm bool_tag) ]

(** [compile_primitive e prim] produces X86-64 instructions for the primitive
   operation named by [prim]; if [prim] isn't a valid operation, it raises an
   error using the s_expression [e] *)
let compile_primitive e = function
  | "add1" ->
      [Add (Reg Rax, operand_of_num 1)]
  | "sub1" ->
      [Sub (Reg Rax, operand_of_num 1)]
  | "zero?" ->
      [Cmp (Reg Rax, operand_of_num 0)] @ zf_to_bool
  | "num?" ->
      [And (Reg Rax, Imm num_mask); Cmp (Reg Rax, Imm num_tag)] @ zf_to_bool
  | "not" ->
      [Cmp (Reg Rax, operand_of_bool false)] @ zf_to_bool
  | _ ->
      raise (Error.Stuck e)

(** [compile_expr e] produces X86-64 instructions for the expression [e] *)
let rec compile_expr : s_exp -> directive list = function
  | Num x ->
      [Mov (Reg Rax, operand_of_num x)]
  | Sym "true" ->
      [Mov (Reg Rax, operand_of_bool true)]
  | Sym "false" ->
      [Mov (Reg Rax, operand_of_bool false)]
  | Lst [Sym f; arg] as exp ->
      compile_expr arg @ compile_primitive exp f
  | e ->
      raise (Error.Stuck e)

(** [compile] produces X86-64 instructions, including frontmatter, for the
   expression [e] *)
let compile (e : s_exp) : directive list =
  [Global "lisp_entry"; Label "lisp_entry"] @ compile_expr e @ [Ret]
