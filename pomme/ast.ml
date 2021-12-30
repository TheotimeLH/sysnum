type localisation = Lexing.position * Lexing.position
type error = { loc : localisation ; msg : string }

type 'a desc = {loc : localisation ; desc : 'a}

type _reg = string
type _int = Const of int | Reg of _reg
type _label = string
type _addr = _int * int

type instr_token =
  | Move | Set
  | Mult | Add | Sub | Neg
  | Not | And | Or | Xor
  | Incrz
  | Load | Save
  | Load_rom
  | Jump | Jump_nul | Jump_non_nul
  | Jump_neg | Jump_non_neg
  | Move_real_clock
  | Sept_batons

type instr =
  | Move of _reg * _reg 
  | Set of _int * _reg
  | Mult of _int * _reg 
  | Add of _int * _reg  
  | Sub of _int * _reg  
  | Neg of _reg
  | Not of _reg 
  | And of _int * _reg  
  | Or of _int * _reg  
  | Xor of _int * _reg 
  | Incrz of _int * _reg 
  | Load of _addr * _reg
  | Save of _int * _reg 
  | Load_rom of _addr * _reg
  | Jump of _label 
  | Jump_nul of _label  
  | Jump_non_nul of _label 
  | Jump_neg of _label  
  | Jump_non_neg of _label 
  | Move_real_clock of _reg 
  | Sept_batons of _reg * _addr

type ligne = Instr of instr | Label of _label

type fichier = ligne desc list
