type localisation = Lexing.position * Lexing.position
type error = { loc : localisation ; msg : string }

type 'a desc = {loc : localisation ; desc : 'a}

type _reg = string
type _int = Const of int | Reg of _reg
type _label = string
type _addr = _reg option * int

type ligne =
  | Label of _label
  | Move of _reg * _reg 
  | Input of _reg
  | Output of _reg
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
  | Save of _reg * _addr
  | Load_rom of _addr * _reg
  | Jump of _label 
  | Jump_nul of _label  
  | Jump_non_nul of _label 
  | Jump_neg of _label  
  | Jump_non_neg of _label 
  | Move_real_clock of _reg 
  | Sept_batons of _reg * _addr

type fichier = ligne desc list
