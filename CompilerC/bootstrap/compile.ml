open Cparse
open Genlab
open Cprint

(* This reference is usefull for generating unique labels
 * I also use it for strings
 * *) 
let compteur = ref 0



(* This function is used to know if the called function is 1 of 5 
 * particular functions (malloc, realloc, ...), to know wether or not
 * I need to extend the result from %eax to %rax or not.
 * *)
let rec is_in x lst = match lst with
        |[] -> false
        |hd::tl when hd=x -> true
        |hd::tl -> is_in x tl


(* Defines the [environnement] type
 * It makes typing the functions easier
 * The string corresponds to the variable name
 * int option gives the localisation in the stack, with regard to %rbp
 * if the value is None, the variable is global
 * *)
type environnement = (string * int option ) list 




let soi = string_of_int

let ios = int_of_string

let print out s = Printf.fprintf out "\t%s\n" s

let printl out s = Printf.fprintf out "%s:\n" s




(* Array of the principle registers
 * *)
let tab = [|"%rdi"; "%rsi"; "%rdx"; "%rcx"; "%r8"; "%r9"|] 


(* This is useful to unstack the environment variables, in OCaml.
 * I use it at the nd of a CFUN or CBLOCK
 * *)        
let rec depile_env (env: environnement) (var: string) : environnement = match env with
        |[] -> failwith "This variable is unknown"
        |(str, _)::tl when str = var -> tl
        |(x)::tl -> x::(depile_env tl var) 





let compile out decl_list = 
	(* I memorize an array of the functions where I won't need to extend %eax
	 * to %rax
	 * *)
        let list_fun_C = ["malloc"; "calloc"; "realloc"; "fopen"; "exit"] in
        let rec my_functions lst = begin match lst with
                |[] -> []
                |CFUN (_, str, _, _)::tl -> str::(my_functions tl)
                |_::tl -> my_functions tl
                end
                in  
        let list_my_fun = my_functions decl_list in
        let list_fun = list_fun_C@list_my_fun in 
        

	(* Compute the min between 0 and the elements of a list
	 * It is useful to find for the maximum depth of the stack,
	 * to know what value I have to give to the environment when i stack it
	 * *)
        let recherche_min (l : int list) : int = List.fold_left min 0 l in         
       
        
        (* Returns a string that gives the location of a variable in memory.
	 * If the variable is not found in the environment it is considered a global 
	 * variable (for example stderr)/
	 * *)
        let rec find_var (str : string) (env : environnement) : string = match env with  
                |[] -> str^"(%rip)"
                |(var, i)::tl when var = str -> 
                        begin match i with
                        | None -> str^"(%rip)"
                        | Some(j) -> (soi j)^"(%rbp)"
                        end
                |(var, i)::tl -> find_var str tl
                        in 
        
        print out ".file \"On_est_la.c \" ";
        print out ".text";
        print out ".align 16";
        
        let (gl, fl) = List.partition (function CDECL(_) -> true | _ -> false) decl_list in 

	(* Global variable declaration in assembly *)
        List.iter (function CDECL(_, x) -> print out (".comm\t"^x^", 8, 8")) gl;

	(* Adding the global variables to the OCaml environment. *) 
	let new_env  = 
                List.map (function CDECL(_, str) -> (str, None) | _ -> failwith "Not a CDECL") gl in 
        let rec compile_fun list_fun out (an_env : environnement) (f : var_declaration) : environnement =
                let CFUN (_ , fun_name, v_d_l, (l_code)) = f in
                print out (".globl\t"^fun_name);
                print out (".type\t"^fun_name^", @function");
                printl out fun_name;
                print out "pushq\t%rbp";
                print out "movq\t%rsp, %rbp"; 

                
		(* stacks the argument and create the new environment *)
                List.iteri (fun  i _ -> if i <= 5 then print out ("pushq\t"^(tab.(i)))) v_d_l; 
                let next_env = (List.mapi (fun i (CDECL(_, var)) ->
                        if i <= 5 then (var, Some(-8* (i+1) ))
                        else (var, Some( 8*(i-4)))) v_d_l)@an_env in
                let next_1_env = compile_code list_fun out next_env l_code in
                
                
		(* put the environment back to the state it was before entering 
		 * the function 
		 * *)
                let next_2_env =
                        List.fold_left depile_env next_1_env 
                                (List.map (function (CDECL(_, str)) -> str) v_d_l) in 
                print out "leave";
                print out "ret";
                next_2_env



                and compile_code list_fun out (a_new_env : environnement)   ((_,code ): loc_code) : environnement   = 
                        begin match code with
                                
                        |CBLOCK (v_d_l, l_code_list) ->
                                let taille = List.length v_d_l in
                                
                                (* memory allocation *)
                                print out ("subq\t$"^(soi (8*taille))^", %rsp"); 
                                
				(* I separate the local variables and the global variables
				 * of my environment so I can compute the location where I 
				 * I will put the new variables
				 * *)
                                let (lclvar, ignore_global) = 
                                        List.partition (function 
                                                |None -> false 
                                                |Some _ -> true) (List.map snd a_new_env) in
                                let lcl_var = List.map (fun (Some i)-> i) lclvar in
                                let prof = recherche_min lcl_var - 8 in
                                
				(* I memorize in the environment the location of the new variables
				 * in the stack of the assembly code
				 * *)
                                let next_0_env = 
                                        (List.mapi (fun i (CDECL( _, name_var)) -> 
                                        (name_var, Some (prof - (8*i)))) v_d_l)@a_new_env in
                                
                                let next_1_env = List.fold_left 
                                        (compile_code list_fun out) next_0_env l_code_list in
                                
				(* Unstack the environment at the end of a bloc
				 * *) 
                                List.fold_left depile_env next_1_env 
                                        (List.map (function (CDECL(_, str)) -> str) v_d_l)
                                
                        |CRETURN (loc_expr) ->   
                                begin match loc_expr with
                                |None ->print out "movq\t$0,%rax";
                                        a_new_env
                                |Some (loc_expr) ->
                                        compile_expr list_fun out a_new_env loc_expr 
                                        end;
                                        print out "leave";
                                        print out "ret";
                                        a_new_env
                        
                        |CEXPR (loc_expr)->    
                                compile_expr list_fun out a_new_env loc_expr;
                                a_new_env
                                
                        |CIF (loc_expr, l_c1, l_c2) -> 
                                compile_expr list_fun out a_new_env loc_expr; 
                                compteur := !compteur + 1;
				(* I create a variable the memorizes the value of [le_compteur]
				 * If I don't, its value may be modified by a compile_code
				 * and then when I need the real value for the jump operator in 
				 * assembly it is problematic.
				 * *)
                                let le_compteur = !compteur in  
                                print out "cmpq\t$0, %rax";
                                print out ("je\t.else"^(soi le_compteur));
                                compile_code list_fun out a_new_env l_c1; 
                                print out ("jmp\t.suite"^(soi le_compteur));
                                
                                printl out (".else"^(soi le_compteur));
                                compile_code list_fun out a_new_env l_c2;
                                printl out (".suite"^(soi le_compteur));
                                a_new_env
                                
                        |CWHILE (loc_expr, loc_code) -> 
                                compteur := !compteur + 1;
                                let le_compteur = !compteur in
                                printl out(".while"^(soi le_compteur));
                                compile_expr list_fun out a_new_env loc_expr;
                                print out "cmpq\t$0, %rax";
                                print out ("je\t.suite"^(soi le_compteur));
                                compile_code list_fun out a_new_env loc_code;
                                print out("jmp\t.while"^(soi le_compteur));
                                printl out (".suite"^(soi le_compteur));
                                a_new_env
                        end
                
                and compile_expr list_fun out (env : environnement) ((_,e) : loc_expr) : environnement = 
                        begin match e with
                        
                        | VAR(v) ->     
                                let str = find_var v env in
                                print out ("movq\t"^(str)^",%rax");
                                env
                        
                        | CST(n) ->     
                                print out ("movq\t$"^(soi n)^", %rax");
                                env
                        
                        | STRING(str) ->
                                let str_print = String.escaped str in
                                compteur := !compteur + 1;
                                let le_compteur = !compteur in
                                print out ("jmp\t.SF"^(soi le_compteur));
                                print out ".section\t.rodata";
                                printl out (".SD"^(soi le_compteur));
                                print out (".string\t\""^str_print^"\"");
                                print out ".section\t.text";
                                printl out (".SF"^(soi le_compteur));
                                print out ("leaq\t.SD"^(soi le_compteur)^"(%rip), %rax");       
                                env
                        
                        | SET_VAR(v, loc_expr) ->   
                                compile_expr list_fun out env loc_expr;
                                print out ("movq\t%rax, "^(find_var v env));
                                env
                        
                        | SET_ARRAY (str, loc_expr_1, loc_expr_2) ->
                                compile_expr list_fun out env loc_expr_2;
                                print out "pushq\t%rax";
                                compile_expr list_fun out env loc_expr_1;
                                print out ("movq\t"^(find_var str env)^" ,%r10");
                                print out "movq\t%rax, %r11";
                                print out "popq\t%rax";
                                print out "movq\t%rax, (%r10,%r11,8)";
                                env
                        
                        | CALL (str, loc_expr_list) ->
				(* the [aux] function takes an [environnement] and
				 * a [loc_expr list] and returns an [environnement]
				 * It compiles the expressions (from left to right),
				 * then put the result in %rax and push it on
				 * the assembly stack. 
				 * *)
                                let rec aux enviro l_c_list  = 
                                        begin match l_c_list with
                                        |[] -> enviro
                                        |(loc_expr)::tl -> 
                                                let next_env = 
                                                        compile_expr list_fun out env loc_expr in
                                                print out "pushq\t%rax";
                                                aux next_env tl
                                        end
                                        in
				(* The List.rev is there to make sure the 
				 * evaluation is done from right to left
				 * *)
                                aux env (List.rev loc_expr_list); 
                                
				(* I put the first 6 arguments (if they exist) 
				 * in the call registers
				 * *)
                                List.iteri 
                                ( fun i _ -> 
                                        ( if i < 6 then print out ("popq\t"^(tab.(i)))
                                          else ())) loc_expr_list;
                                
				(* put 0 in %rax before the call
				 * *)
                                print out "movq\t$0, %rax";
                                print out ("call\t"^str);

                                (* extend %eax to %rax if needed
                                 * *)
                                if is_in str list_fun then () 
                                else print out "movslq\t%eax, %rax"; 
                                env
                        
                        | OP1 (mon_op, l_expr) -> 
				(* [actualise] takes a string (["addq"] pr ["subq"]
				 * depending on the operation) and a variable name
				 * returs unit
				 * It is useful for crementation in assembly
				 * It helps factorizing the code
				 * *)
                                let actualise (op : string) (str :string) : unit = 
                                        let place = 
                                                find_var str env in 
                                        print out (op^"$1, "^place) in
                                        begin match mon_op with
                                        
                                        |M_MINUS ->     
                                                compile_expr list_fun out env l_expr;
                                                print out "negq\t%rax";
                                        
                                        |M_NOT ->       
                                                compile_expr list_fun out env l_expr;
                                                print out "cmpq\t$0, %rax";
                                                compteur := !compteur +1;
                                                let le_compteur = !compteur in
                                                print out ("je\t.if"^(soi !compteur));
                                                print out "movq\t$0, %rax";
                                                print out ("jmp\t.suite"^(soi le_compteur));
                                                printl out (".if"^(soi le_compteur));
                                                print out "movq\t$1, %rax";
                                                printl out (".suite"^(soi le_compteur));
					| smthg -> begin match l_expr with
     						|(_, VAR(str)) -> begin match mon_op with
                                        		|M_POST_INC ->  
                                                		compile_expr list_fun out env l_expr;
							(* Updating the environment after computations *)
                                                		actualise "addq\t" str 
                                                
                                        		|M_POST_DEC ->  
                                                		compile_expr list_fun out env l_expr;
                                                		actualise "subq\t" str
                                                
                                        		|M_PRE_INC ->   
                                                		actualise "addq\t" str;
                                                		compile_expr list_fun out env l_expr;
                                                		ignore()
                                                
                                        		|M_PRE_DEC ->   
                                                		actualise "subq\t" str;
                                                		compile_expr list_fun out env l_expr;
                                                		ignore()
                                        			end
						|(_, OP2(S_INDEX, lexpr_1, lexpr_2)) -> 
                                                        print out "pushq\t%rbx";
							compile_expr list_fun out env lexpr_2;
                                                	print out "pushq\t%rax";
                                                	compile_expr list_fun out env lexpr_1;
                                                	print out "popq\t%rbx";
							begin match mon_op with
                                                        (* I could have factorized the code with [actualise]
                                                         * I didn't get the time
                                                         * *)
							|M_POST_INC -> 
								print out "movq\t(%rax, %rbx, 8), %r10"; 
								print out "addq\t$1, (%rax, %rbx, 8)";
								print out "movq\t%r10, %rax"

							|M_PRE_INC ->
								print out "addq\t$1, (%rax, %rbx, 8)";
								print out "movq\t(%rax, %rbx, 8), %rax";
		
							|M_POST_DEC -> 
								print out "movq\t(%rax, %rbx, 8), %r10"; 
								print out "subq\t$1, (%rax, %rbx, 8)";
								print out "movq\t%r10, %rax"
							|M_PRE_DEC ->
								print out "subq\t$1, (%rax, %rbx, 8)";
								print out "movq\t(%rax, %rbx, 8), %rax";
                                                        end;	
                                                        print out "popq\t%rbx"


					end
                                
                                end;
                                env
                        
                        | OP2(bin_op, (loc_expr1), (loc_expr2)) ->   
                                print out "pushq\t%rbx";
                                let add_sub_mul op =    
                                        compile_expr list_fun out env loc_expr2;
                                        print out "pushq\t%rax";
                                        compile_expr list_fun out env loc_expr1;
                                        print out "popq\t%rbx";
                                        print out (op^"\t%rbx, %rax") in

                                let div_mod op =        
                                        compile_expr list_fun out env loc_expr2;
                                        print out "movq\t%rax, %rbx";
                                        compile_expr list_fun out env loc_expr1;
                                        print out "cqto";
                                        print out "idivq\t%rbx";
                                        print out ("movq\t%"^op^", %rax") in
                                begin match bin_op with
                                        
                                        |S_MUL ->       
                                                add_sub_mul "imulq";
                                        |S_DIV ->       
                                                div_mod "rax";
                                        |S_MOD ->       
                                                div_mod "rdx";
                                        |S_INDEX ->     
                                                compile_expr list_fun out env loc_expr2;
                                                print out "pushq\t%rax";
                                                compile_expr list_fun out env loc_expr1;
                                                print out "popq\t%rbx";
                                                print out "movq\t(%rax, %rbx, 8), %rax";
                                        |S_ADD ->       
                                                add_sub_mul "addq";
                                        |S_SUB ->       
                                                add_sub_mul "subq";
                                end;
                                print out "popq\t%rbx";
                                env
                        
                        |CMP(cmp_op,(loc_expr1), (loc_expr2)) ->
                                print out "pushq\t%rbx";
                                let comparator cmp loc_expr1 loc_expr2 = 
                                        compile_expr list_fun out env loc_expr2;
                                        print out "pushq\t%rax";
                                        compile_expr list_fun out env loc_expr1;
                                        compteur := !compteur + 1;
                                        let le_compteur = !compteur in
                                        print out "popq\t%rbx";
                                        print out "cmpq\t%rax, %rbx";
                                        print out (cmp^"\t.comp"^(soi le_compteur));
                                        print out "movq\t$0, %rax";
                                        print out ("jmp\t.suite"^(soi le_compteur));
                                        printl out (".comp"^(soi le_compteur));
                                        print out "movq\t$1, %rax";
                                        printl out (".suite"^(soi le_compteur)) in                    
                                        begin match cmp_op with
                                                |C_LT -> comparator "jg" loc_expr1 loc_expr2;
                                                |C_LE -> comparator "jge" loc_expr1 loc_expr2;
                                                |C_EQ -> comparator "je" loc_expr1 loc_expr2;
                                        end;
                                print out "popq\t%rbx";        
                                env
                        
                        |EIF((loc_expr_cond), (loc_expr1), (loc_expr2)) ->
                                compile_expr list_fun out env loc_expr_cond;
                                compteur := !compteur + 1;
                                let le_compteur = !compteur in
                                print out "cmpq\t$0, %rax";
                                print out ("je\t.if"^(soi le_compteur));
                                compile_expr list_fun out env loc_expr1;
                                print out ("jmp\t.suite"^(soi le_compteur));
                                printl out (".if"^(soi le_compteur));
                                compile_expr list_fun out env loc_expr2;
                                printl out (".suite"^(soi le_compteur));
                                env
                        
                        |ESEQ(loc_expr_list) -> 
                                List.fold_left (compile_expr list_fun out) env loc_expr_list
                end
        in List.fold_left (compile_fun list_fun out) new_env fl;
        ignore()
