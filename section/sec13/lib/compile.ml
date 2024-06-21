open Util
open S_exp
open Shared
open Error
open Directive

(** constants used for tagging values at runtime *)
let num_shift = 2

let num_mask = 0b11
let num_tag = 0b00
let bool_shift = 7
let bool_mask = 0b1111111
let bool_tag = 0b0011111
let heap_mask = 0b111
let pair_tag = 0b010
let nil_tag = 0b11111111

type symtab = int Symtab.symtab

let function_label s =
  let nasm_char c =
    match c with
    | 'a' .. 'z'
    | 'A' .. 'Z'
    | '0' .. '9'
    | '_' | '$' | '#' | '@' | '~' | '.' | '?' ->
        c
    | _ -> '_'
  in
  Printf.sprintf "function_%s_%d" (String.map nasm_char s) (Hashtbl.hash s)

(** [operand_of_num x] returns the runtime representation of the number [x] as an
   operand for instructions *)
let operand_of_num (x : int) : operand = Imm ((x lsl num_shift) lor num_tag)

(** [operand_of_bool b] returns the runtime representation of the boolean [b] as an
   operand for instructions *)
let operand_of_bool (b : bool) : operand =
  Imm (((if b then 1 else 0) lsl bool_shift) lor bool_tag)

let operand_of_nil = Imm nil_tag

let zf_to_bool =
  [
    Mov (Reg Rax, Imm 0);
    Setz (Reg Rax);
    Shl (Reg Rax, Imm bool_shift);
    Or (Reg Rax, Imm bool_tag);
  ]

let setl_bool =
  [
    Mov (Reg Rax, Imm 0);
    Setl (Reg Rax);
    Shl (Reg Rax, Imm bool_shift);
    Or (Reg Rax, Imm bool_tag);
  ]

let stack_address (index : int) : operand = MemOffset (Imm index, Reg Rsp)

let ensure condition err_msg =
  let msg_label = gensym "emsg" in
  let continue_label = gensym "continue" in
  condition
  @ [
      Je continue_label;
      LeaLabel (Reg Rdi, msg_label);
      Jmp "lisp_error";
      Label msg_label;
      DqString err_msg;
      Label continue_label;
    ]

let ensure_type mask tag op e =
  ensure
    [ Mov (Reg R8, op); And (Reg R8, Imm mask); Cmp (Reg R8, Imm tag) ]
    (string_of_s_exp e)

let ensure_num = ensure_type num_mask num_tag
let ensure_pair = ensure_type heap_mask pair_tag

let align_stack_index (stack_index : int) : int =
  if stack_index mod 16 = -8 then stack_index else stack_index - 8

(** [compile_0ary_primitive e prim] produces X86-64 instructions for the zero-arity
   primitive operation named by [prim]; if [prim] isn't a valid zero-arity operation,
   it raises an error using the s_expression [e] *)
let compile_0ary_primitive stack_index e = function
  | "read-num" ->
      [
        Mov (stack_address stack_index, Reg Rdi);
        Add (Reg Rsp, Imm (align_stack_index stack_index));
        Call "read_num";
        Sub (Reg Rsp, Imm (align_stack_index stack_index));
        Mov (Reg Rdi, stack_address stack_index);
      ]
  | "newline" ->
      [
        Mov (stack_address stack_index, Reg Rdi);
        Add (Reg Rsp, Imm (align_stack_index stack_index));
        Call "print_newline";
        Sub (Reg Rsp, Imm (align_stack_index stack_index));
        Mov (Reg Rdi, stack_address stack_index);
        Mov (Reg Rax, operand_of_bool true);
      ]
  | _ -> raise (Stuck e)

(** [compile_unary_primitive e prim] produces X86-64 instructions for the unary
   primitive operation named by [prim]; if [prim] isn't a valid unary operation,
   it raises an error using the s_expression [e] *)
let compile_unary_primitive stack_index e = function
  | "add1" -> ensure_num (Reg Rax) e @ [ Add (Reg Rax, operand_of_num 1) ]
  | "sub1" -> ensure_num (Reg Rax) e @ [ Sub (Reg Rax, operand_of_num 1) ]
  | "zero?" -> [ Cmp (Reg Rax, operand_of_num 0) ] @ zf_to_bool
  | "num?" ->
      [ And (Reg Rax, Imm num_mask); Cmp (Reg Rax, Imm num_tag) ] @ zf_to_bool
  | "not" -> [ Cmp (Reg Rax, operand_of_bool false) ] @ zf_to_bool
  | "pair?" ->
      [ And (Reg Rax, Imm heap_mask); Cmp (Reg Rax, Imm pair_tag) ] @ zf_to_bool
  | "left" ->
      ensure_pair (Reg Rax) e
      @ [ Mov (Reg Rax, MemOffset (Reg Rax, Imm (-pair_tag))) ]
  | "right" ->
      ensure_pair (Reg Rax) e
      @ [ Mov (Reg Rax, MemOffset (Reg Rax, Imm (-pair_tag + 8))) ]
  | "empty?" -> [ Cmp (Reg Rax, operand_of_nil) ] @ zf_to_bool
  | "print" ->
      [
        Mov (stack_address stack_index, Reg Rdi);
        Mov (Reg Rdi, Reg Rax);
        Add (Reg Rsp, Imm (align_stack_index stack_index));
        Call "print_value";
        Sub (Reg Rsp, Imm (align_stack_index stack_index));
        Mov (Reg Rdi, stack_address stack_index);
        Mov (Reg Rax, operand_of_bool true);
      ]
  | _ -> raise (Stuck e)

(** [compile_binary_primitive stack_index e prim] produces X86-64 instructions
   for the binary primitive operation named by [prim]; if [prim] isn't a valid
   binary operation, it raises an error using the s_expression [e] *)
let compile_binary_primitive stack_index e = function
  | "+" ->
      ensure_num (Reg Rax) e
      @ ensure_num (stack_address stack_index) e
      @ [ Add (Reg Rax, stack_address stack_index) ]
  | "-" ->
      ensure_num (Reg Rax) e
      @ ensure_num (stack_address stack_index) e
      @ [
          Mov (Reg R8, Reg Rax);
          Mov (Reg Rax, stack_address stack_index);
          Sub (Reg Rax, Reg R8);
        ]
  | "=" ->
      ensure_num (Reg Rax) e
      @ ensure_num (stack_address stack_index) e
      @ [ Cmp (stack_address stack_index, Reg Rax) ]
      @ zf_to_bool
  | "<" ->
      ensure_num (Reg Rax) e
      @ ensure_num (stack_address stack_index) e
      @ [ Cmp (stack_address stack_index, Reg Rax) ]
      @ setl_bool
  | "pair" ->
      [
        Mov (Reg R8, stack_address stack_index);
        Mov (MemOffset (Reg Rdi, Imm 0), Reg R8);
        Mov (MemOffset (Reg Rdi, Imm 8), Reg Rax);
        Mov (Reg Rax, Reg Rdi);
        Or (Reg Rax, Imm pair_tag);
        Add (Reg Rdi, Imm 16);
      ]
  | _ -> raise (Stuck e)

let align n alignment =
  if n mod alignment = 0 then n else n + (alignment - (n mod alignment))

(** [compile_expr e] produces X86-64 instructions for the expression [e] *)
let rec compile_expr (defns : defn list) (tab : symtab) (stack_index : int) :
    s_exp -> directive list = function
  | Num x -> [ Mov (Reg Rax, operand_of_num x) ]
  | Sym "true" -> [ Mov (Reg Rax, operand_of_bool true) ]
  | Sym "false" -> [ Mov (Reg Rax, operand_of_bool false) ]
  | Sym var when Symtab.mem var tab ->
      [ Mov (Reg Rax, stack_address (Symtab.find var tab)) ]
  | Lst [] -> [ Mov (Reg Rax, operand_of_nil) ]
  | Lst [ Sym "if"; test_expr; then_expr; else_expr ] ->
      let then_label = gensym "then" in
      let else_label = gensym "else" in
      let continue_label = gensym "continue" in
      compile_expr defns tab stack_index test_expr
      @ [ Cmp (Reg Rax, operand_of_bool false); Je else_label ]
      @ [ Label then_label ]
      @ compile_expr defns tab stack_index then_expr
      @ [ Jmp continue_label ] @ [ Label else_label ]
      @ compile_expr defns tab stack_index else_expr
      @ [ Label continue_label ]
  | Lst [ Sym "let"; Lst [ Lst [ Sym var; exp ] ]; body ] ->
      compile_expr defns tab stack_index exp
      @ [ Mov (stack_address stack_index, Reg Rax) ]
      @ compile_expr defns
          (Symtab.add var stack_index tab)
          (stack_index - 8) body
  | Lst (Sym "do" :: exps) when List.length exps > 0 ->
      List.concat_map (compile_expr defns tab stack_index) exps
  | Lst [ Sym "apply"; Sym f; args_list ] as e when is_defn defns f ->
      let stack_base = align_stack_index (stack_index + 8) in
      let loop_label = gensym "loop" in
      let call_label = gensym "call" in
      let error_label = gensym "error" in
      let emsg_label = gensym "emsg" in
      let error =
        [
          Label error_label;
          LeaLabel (Reg Rdi, emsg_label);
          Jmp "lisp_error";
          Label emsg_label;
          DqString (string_of_s_exp e);
        ]
      in
      let call =
        [
          Label call_label;
          Add (Reg Rsp, Imm stack_base);
          Call (function_label f);
          Sub (Reg Rsp, Imm stack_base);
        ]
      in
      (* assumes argument list is in rax *)
      let args_to_stack =
        [
          Mov (MemOffset (Reg Rsp, Imm (stack_base - 16)), Imm 0);
          Mov (Reg R9, Imm (stack_base - 24));
          Label loop_label;
          Cmp (Reg Rax, operand_of_nil);
          Je call_label;
          (* rax isn't nil, so make sure it's a pair *)
          Mov (Reg R8, Reg Rax);
          And (Reg R8, Imm heap_mask);
          Cmp (Reg R8, Imm pair_tag);
          Jne error_label;
          Mov (Reg R8, MemOffset (Reg Rax, Imm (-pair_tag)));
          Mov (MemOffset (Reg Rsp, Reg R9), Reg R8);
          Sub (Reg R9, Imm 8);
          Mov (Reg Rax, MemOffset (Reg Rax, Imm (8 - pair_tag)));
          Add (MemOffset (Reg Rsp, Imm (stack_base - 16)), Imm 1);
          Jmp loop_label;
        ]
      in
      compile_expr defns tab stack_index args_list
      @ args_to_stack @ error @ call
  | Lst (Sym f :: args) when is_defn defns f ->
      let stack_base = align_stack_index (stack_index + 8) in
      let compiled_args =
        args
        |> List.mapi (fun i arg ->
               compile_expr defns tab (stack_base - ((i + 3) * 8)) arg
               @ [ Mov (stack_address (stack_base - ((i + 3) * 8)), Reg Rax) ])
        |> List.concat
      in
      [ Mov (stack_address (stack_base - 16), Imm (List.length args)) ]
      @ compiled_args
      @ [
          Add (Reg Rsp, Imm stack_base);
          Call (function_label f);
          Sub (Reg Rsp, Imm stack_base);
        ]
  | Lst [ Sym f ] as exp -> compile_0ary_primitive stack_index exp f
  | Lst [ Sym f; arg ] as exp ->
      compile_expr defns tab stack_index arg
      @ compile_unary_primitive stack_index exp f
  | Lst [ Sym f; arg1; arg2 ] as exp ->
      compile_expr defns tab stack_index arg1
      @ [ Mov (stack_address stack_index, Reg Rax) ]
      @ compile_expr defns tab (stack_index - 8) arg2
      @ compile_binary_primitive stack_index exp f
  | e -> raise (Stuck e)

(** [compile_defn defns defn] produces X86-64 instructions for the function
   definition [defn] **)
let compile_defn (defns : defn list) defn : directive list =
  let ftab_args =
    defn.args |> List.mapi (fun i arg -> (arg, (i + 2) * -8)) |> Symtab.of_list
  in
  let ftab =
    match defn.rest with
    | None -> ftab_args
    | Some rest -> Symtab.add rest ((List.length defn.args + 2) * -8) ftab_args
  in
  let good_arity_label = gensym "good_arity" in
  let arity_error_label = gensym "arity_error_msg" in
  let arity_check =
    [
      Mov (Reg R8, MemOffset (Reg Rsp, Imm (-8)));
      Cmp (Reg R8, Imm (List.length defn.args));
    ]
    @ [
        (if Option.is_some defn.rest then Jnl good_arity_label
        else Je good_arity_label);
      ]
    @ [
        LeaLabel (Reg Rdi, arity_error_label);
        Jmp "lisp_error";
        Label arity_error_label;
        DqString "arity-error";
        Label good_arity_label;
      ]
  in
  let rest_from_stack =
    if Option.is_some defn.rest then
      let loop_label = gensym "loop" in
      let continue_label = gensym "continue" in
      [
        Mov (Reg R9, operand_of_nil);
        Label loop_label;
        Cmp (Reg R8, Imm (List.length defn.args));
        Je continue_label;
        Mov (Reg Rax, Reg R8);
        Sub (Reg R8, Imm 1);
        Add (Reg Rax, Imm 1);
        Mov (Reg R10, Imm (-8));
        Mul (Reg R10);
        Mov (Reg Rax, MemOffset (Reg Rsp, Reg Rax));
        Mov (MemOffset (Reg Rdi, Imm 0), Reg Rax);
        Mov (MemOffset (Reg Rdi, Imm 8), Reg R9);
        Mov (Reg R9, Reg Rdi);
        Or (Reg R9, Imm pair_tag);
        Add (Reg Rdi, Imm 16);
        Jmp loop_label;
        Label continue_label;
        Mov (Reg Rax, Reg R8);
        Add (Reg Rax, Imm 2);
        Mov (Reg R10, Imm (-8));
        Mul (Reg R10);
        Mov (MemOffset (Reg Rsp, Reg Rax), Reg R9);
      ]
    else []
  in
  [ Label (function_label defn.name) ]
  @ arity_check @ rest_from_stack
  @ compile_expr defns ftab ((Symtab.cardinal ftab + 2) * -8) defn.body
  @ [ Ret ]

(** [compile] produces X86-64 instructions, including frontmatter, for the
   expression [e] *)
let compile (exps : s_exp list) =
  let defns, body = defns_and_body exps in
  [
    Global "lisp_entry";
    Extern "lisp_error";
    Extern "read_num";
    Extern "print_value";
    Extern "print_newline";
    Section "text";
  ]
  @ List.concat_map (compile_defn defns) defns
  @ [ Label "lisp_entry" ]
  @ compile_expr defns Symtab.empty (-8) body
  @ [ Ret ]
