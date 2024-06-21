type expr
  = Num of float
  | Var of string
  | Log of expr
  | Sin of expr
  | Cos of expr
  | Tan of expr
  | Negate of expr
  | Group of expr
  | Plus of expr * expr
  | Minus of expr * expr
  | Times of expr * expr
  | Divide of expr * expr
  | Exp of expr * expr

type stmt
  = Print of expr
  | Assign of string * expr
