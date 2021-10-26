open Cparse

let indentation = ref 0

let rec indente n = if n=0 then ""
				else (indente (n-1))^"  "

let indenter out () = Format.fprintf out "%s" (indente !indentation)

let ecrire out s = Format.fprintf out "%s" s

let print_mop out op=
	match op with
		M_MINUS -> ecrire out "-"
	|	M_NOT -> ecrire out "!"
	|	M_POST_INC -> ecrire out "(post)++"
	|	M_POST_DEC -> ecrire out "(post)--"
	|	M_PRE_INC -> ecrire out "(pre)++"
	|	M_PRE_DEC -> ecrire out "(pre)--"

let print_bop out op =
	match op with
		S_MUL -> ecrire out " * "
	|	S_DIV -> ecrire out " / "
	|	S_MOD -> ecrire out " % "
	|	S_ADD -> ecrire out " + "
	|	S_SUB -> ecrire out " - "
	|	S_INDEX -> ecrire out "[]"
	
let print_cop out op =
	match op with
		C_LT -> ecrire out " < "
	|	C_LE -> ecrire out " <= "
	|	C_EQ -> ecrire out " == "

let rec print_expr out e =
	match e with
		_,VAR(s) -> ecrire out ("VAR"^s^" ") 
        |	_,CST(a) -> ecrire out "CST\t"; Format.fprintf out "%d " a
        |	_,STRING(s) -> ecrire out "STRING "; Format.fprintf out "\"%s\"" s
        |	_,SET_VAR(s,le) -> ecrire out "SET_var "; Format.fprintf out "(%s = " s; print_expr out le; ecrire out ")"
        |	_,SET_ARRAY(s,le1,le2) -> ecrire out "Set_array "; Format.fprintf out "(%s[" s; print_expr out le1; ecrire out "]= "; print_expr out le2; ecrire out ")" 
        |	_,CALL(s,lel) -> ecrire out " CALL "; Format.fprintf out "%s(" s; List.fold_left (fun () -> (fun x -> print_expr out x; ecrire out "," )) () lel; ecrire out ")"
	|	_,OP1(op,le) -> print_mop out op; ecrire out "(" ; print_expr out le; ecrire out ")" 
	|	_,OP2(op,le1,le2) -> ecrire out "(" ; print_expr out le1; print_bop out op; print_expr out le2; ecrire out ")"
	|	_,CMP(op,le1,le2) -> ecrire out "(" ; print_expr out le1; print_cop out op; print_expr out le2; ecrire out ")"
	|	_,EIF(le1,le2,le3) -> ecrire out "(" ; print_expr out le1; ecrire out " ? "; print_expr out le2; ecrire out " : " ; print_expr out le3; ecrire out ")"
	|	_,ESEQ(lel) -> List.fold_left (fun () -> (fun x -> print_expr out x;ecrire out ";\n";indenter out ())) () lel

and print_code out c =
	match c with
                _,CBLOCK(dl,lcl) -> ecrire out "CBLOCK "; ecrire out "{\n" ; indentation := !indentation + 1; indenter out (); 
							print_ast out dl;
							List.fold_left (fun () -> (fun x -> print_code out x;ecrire out ";\n";indenter out () )) () lcl;
							indentation := !indentation -1; ecrire out "}\n";indenter out () 
	|	_,CEXPR(le) -> print_expr out le
	|	_,CIF(le,lc1,lc2) -> ecrire out "IF : " ; print_expr out le; ecrire out "\n";indenter out () ;
							 print_code out lc1;
							 ecrire out "ELSE :\n" ;indenter out ();
							 print_code out lc2;
							 ecrire out "FI\n";indenter out () 
	|	_,CWHILE(le,lc) -> ecrire out "WHILE : " ; print_expr out le; ecrire out "\n";indenter out () ;
							print_code out lc
	|	_,CRETURN(a) -> match a with None -> ecrire out "RETURN\n";indenter out () | Some x -> ecrire out "RETURN " ; print_expr out x; ecrire out "\n" ;indenter out ();
 

and print_dec out dec =
	match dec with
                CDECL(e,s) -> ecrire out ("CDECL "); ecrire out ("int "^s^"\n") ;indenter out ()
	|	CFUN(e,s,dl,c) -> ecrire out (" fonction : "^s^"(") ;
						  print_ast out dl;
						  ecrire out ")\n" ;indenter out ();
						  print_ast out dl;
						  print_code out c;
						  ecrire out "fin fonction\n" ;indenter out ()

and print_ast out dec_list =
	match dec_list with
		[]     -> ()
	|	dec::t -> print_dec out dec; print_ast out t

let print_declarations out dec_list =
	ecrire out "Pourquoi ?\n" 
	
let print_locator out nom fl fc ll lc = 
	ecrire out "C'est quoi cette fonction?\n" 


	
