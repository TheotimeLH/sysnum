%{
  open Ast
  exception Parser_error of string
%}

/* Déclaration des tokens */

%token EOF
%token <string> LABEL
%token <string> REG
%token <int> CONST
%token MOVE SET INPUT OUTPUT MULT ADD SUB NEG NOT AND OR XOR
%token INCRZ LOAD SAVE LOAD_ROM JUMP JUMP_NUL JUMP_NON_NUL
%token JUMP_NEG JUMP_NON_NEG MOVE_REAL_CLOCK SEPT_BATONS
%token COLON
%token DOLLAR
%token PLUS LPAR RPAR

/* Pas de priorité à gérer */

/* Point d'entrée de la grammaire */
%start fichier

/* Type de retour */
%type <Ast.fichier> fichier

%%

fichier: l=ligne* ; EOF {l}

ligne:
  | lbl = LABEL ; COLON 
    { {loc = ($startpos,$endpos) ; desc = Label lbl } }
  | MOVE ; reg1 = REG ; reg2 = REG
    { {loc = ($startpos,$endpos) ; desc = Move (reg1,reg2) } } 
  | SET ; int1 = gr_int ; reg2 = REG
    { {loc = ($startpos,$endpos) ; desc = Set (int1,reg2) } }
  | INPUT ; reg1 = REG
    { {loc = ($startpos,$endpos) ; desc = Input reg1 } } 
  | OUTPUT ; reg1 = REG
    { {loc = ($startpos,$endpos) ; desc = Output reg1 } } 
  | ADD ; int1 = gr_int ; reg2 = REG
    { {loc = ($startpos,$endpos) ; desc = Add (int1,reg2) } } 
  | MULT ; int1 = gr_int ; reg2 = REG
    { {loc = ($startpos,$endpos) ; desc = Mult (int1,reg2) } }
  | SUB ; int1 = gr_int ; reg2 = REG
    { {loc = ($startpos,$endpos) ; desc = Sub (int1,reg2) } } 
  | NEG ; reg1 = REG
    { {loc = ($startpos,$endpos) ; desc = Neg reg1 } } 
  | NOT ; reg1 = REG
    { {loc = ($startpos,$endpos) ; desc = Not reg1 } }
  | AND ; int1 = gr_int ; reg2 = REG
    { {loc = ($startpos,$endpos) ; desc = And (int1,reg2) } }
  | OR ; int1 = gr_int ; reg2 = REG
    { {loc = ($startpos,$endpos) ; desc = Or (int1,reg2) } }
  | XOR ; int1 = gr_int ; reg2 = REG
    { {loc = ($startpos,$endpos) ; desc = Xor (int1,reg2) } }
  | INCRZ ; int1 = gr_int ; reg2 = REG
    { {loc = ($startpos,$endpos) ; desc = Incrz (int1,reg2) } }
  | LOAD ; addr1 = gr_addr ; reg2 = REG
    { {loc = ($startpos,$endpos) ; desc = Load (addr1,reg2) } }
  | SAVE ; reg1 = REG ; addr2 = gr_addr
    { {loc = ($startpos,$endpos) ; desc = Save (reg1,addr2) } }
  | LOAD_ROM ; addr1 = gr_addr ; reg2 = REG
    { {loc = ($startpos,$endpos) ; desc = Load_rom (addr1,reg2) } }
  | JUMP ; lbl = LABEL
    { {loc = ($startpos,$endpos) ; desc = Jump lbl } }
  | JUMP_NUL ; lbl = LABEL
    { {loc = ($startpos,$endpos) ; desc = Jump_nul lbl } }
  | JUMP_NON_NUL ; lbl = LABEL
    { {loc = ($startpos,$endpos) ; desc = Jump_non_nul lbl } }
  | JUMP_NEG ; lbl = LABEL
    { {loc = ($startpos,$endpos) ; desc = Jump_neg lbl } }
  | JUMP_NON_NEG ; lbl = LABEL
    { {loc = ($startpos,$endpos) ; desc = Jump_non_neg lbl } }
  | MOVE_REAL_CLOCK ; reg1 = REG
    { {loc = ($startpos,$endpos) ; desc = Move_real_clock reg1 } }
  | SEPT_BATONS ; reg1 = REG ; addr2 = gr_addr
    { {loc = ($startpos,$endpos) ; desc = Sept_batons (reg1,addr2) } }


gr_int:
  | n = CONST {Const n}
  | DOLLAR ; r = REG {Reg r}

gr_addr:
  | LPAR ; DOLLAR ; r = REG ; RPAR { (Some r,0) }
  | LPAR ; n = CONST ; RPAR { (None,n) }
  | LPAR ; DOLLAR ; r = REG ; PLUS ; n = CONST ; RPAR { (Some r,n) }

