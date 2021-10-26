type mon_op = M_MINUS | M_NOT | M_POST_INC | M_POST_DEC | M_PRE_INC | M_PRE_DEC
(** Unary operations:
  M_MINUS : computes the additive inverse
  M_NOT : computes the negation of the logical expression
  M_POST_INC : post-increment e++
  M_POST_DEC : post-decrement e--
  M_PRE_INC : pre-increment ++e
  M_PRE_DEC : pre-decrement --e
  *)

type bin_op = S_MUL | S_DIV | S_MOD | S_ADD | S_SUB | S_INDEX
(** binary operations:
  S_MUL : integer product
  S_DIV : integer division (quotient)
  S_MOD : integer division (remainder)
  S_ADD : integer sum
  S_SUB : integer substraction
  S_INDEX : access to an element of an array a[i]
  *)


type cmp_op = C_LT | C_LE | C_EQ
(** Comparison operators
  C_LT (less than) : <
  C_LE (less or equal to : <=
  C_EQ (equal) : ==
  *)

type loc_expr = Error.locator * expr
and expr =

  | VAR of string (** a variable --- always an int. *)
  | CST of int (** integer constant *)
  | STRING of string (** constant string. *)
  | SET_VAR of string * loc_expr (** assignment x=e. *)
  | SET_ARRAY of string * loc_expr * loc_expr (** assignment x[e]=e'. *)
  | CALL of string * loc_expr list (** call of function f(e1,...,en) *)

  | OP1 of mon_op * loc_expr
    (** OP1(mop, e) stands for -e, ~e, e++, e--, ++e, or --e. *)
  | OP2 of bin_op * loc_expr * loc_expr
    (** OP2(bop,e,e') stands for e*e', e/e', e%e',
                             e+e', e-e', ou e[e']. *)
  | CMP of cmp_op * loc_expr * loc_expr
    (** CMP(cop,e,e') stands for e<e', e<=e', ou e==e' *)
  | EIF of loc_expr * loc_expr * loc_expr
    (** EIF(e1,e2,e3) is e1?e2:e3 *)
  | ESEQ of loc_expr list
    (** e1, ..., en [sequence, similar to  e1;e2 code wise];
      if n=0, corresponds to skip. *)

type var_declaration =
  | CDECL of Error.locator * string
    (** int declaration. *)
  | CFUN of Error.locator * string * var_declaration list * loc_code
    (** function with its arugments, and its code *)
and loc_code = Error.locator * code
and code =
    CBLOCK of var_declaration list * loc_code list (** { declarations; code; } *)
  | CEXPR of loc_expr (** an expression e; seen as an instruction. *)
  | CIF of loc_expr * loc_code * loc_code (** if (e) c1; else c2; *)
  | CWHILE of loc_expr * loc_code (** while (e) c1; *)
  | CRETURN of loc_expr option (** return; or return (e); *)

val cline : int ref
val ccol : int ref
val oldcline : int ref
val oldccol : int ref
val cfile : string ref

val getloc : unit -> string * int * int * int * int

val loc_of_expr : Error.locator*'a -> Error.locator
val e_of_expr : loc_expr -> expr
