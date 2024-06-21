%{
  open Ast
%}

%token <float> NUMBER
%token PRINT NEWLINE
%token PLUS
%token EOF

%start <stmt list> main

%%

main:
  | s = stmt NEWLINE rest = main
      { s :: rest }
  | s = stmt EOF
      { [s] }
  | EOF
      { [] }

stmt:
  | PRINT e = expr
      { Print e }

expr:
  | e = expr PLUS l = literal
      { Plus (e, l) }
  | l = literal
      { l }

literal:
  | n = NUMBER
      { Num n }
