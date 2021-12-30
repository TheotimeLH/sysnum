(* Lexer pour compiler l'assembleur pomme *)

{
  open Lexing
  open Parser

  exception Lexer_error of string
  exception Lexer_non_fini of error
  exception Interruption

  let instructions = Hashtbl.create 21
  let () = List.iter (fun (s,t) -> Hashtbl.add keywords s t)
    ["move",MOVE ; "set",SET ;
     "mult",MULT ; "add",ADD ; "sub",SUB ; "neg",NEG ;
     "not",NOT ; "and",AND ; "or",OR ; "xor",XOR ;
     "incrz",INCRZ ;
     "load",LOAD ; "save",SAVE ;
     "load_rom",LOAD_ROM ;
     "jump",JUMP ; "jump_nul",JUMP_NUL ; "jump_non_nul",JUMP_NON_NUL ;
     "jump_neg",JUMP_NEG ; "jump_non_neg",JUMP_NON_NEG ;
     "move_real_clock",MOVE_REAL_CLOCK ;
     "sept_batons",SEPT_BATONS ]
}

let chiffre = ['0'-'9']
let l_min = ['a'-'z']
let l_maj = ['A'-'Z']
let label = l_maj (l_min | l_maj | chiffre | '-' | '_')*
let entier = chiffre*
let reg = 'r' (['1' - '4'] | "ax" | "bx" | "cx" | "ck")
let instru = l_min*

rule token = parse
  | [' ' '\t']+ | "//" [^'\n']* {token lexbuf}
  | '\n' 	{ new_line lexbuf ; token lexbuf }
  | "/*"	{ 
      let pos = lexbuf.lex_start_p,lexbuf.lex_curr_p in
      try comment lexbuf with Interruption -> raise
      (Lexer_non_fini { loc=pos ; msg="Commentaire non fermé." } ) 
    }
  | entier as s { 
      try CONST (int_of_string s) with _ ->
      raise (Lexer_error "Constante entière trop grande.") 
    }
  | label as s { LABEL s}
  | ':' {COLON}
  | '$' {DOLLAR}
  | reg as s { REG s }
  | '(' {LPAR}
  | ')' {RPAR}
  | '+' {PLUS}
  | instru as s {
      try Hashtbl.find instructions s
      with Not_found -> raise Lexing_error "Instruction inconnue."
    }
  | eof {EOF}
  | _ as c {raise (Lexer_error ("Caractère illégal: " ^ String.make 1 c) ) }



and comment = parse
  | "*/" 	{token lexbuf}
	| '\n' 	{ new_line lexbuf ; comment lexbuf }
  | _  		{comment lexbuf}
  | eof 	{raise Interruption}
