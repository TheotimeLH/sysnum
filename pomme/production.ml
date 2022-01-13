(* Production du code binaire pour un fichier pomme. *)

open Ast

exception Prod_error of error

(* === Fonctions auxiliaires === *)
(* Chaque ligne-instruction est représenté sur 32 bits :
   8 pour l'instruction, 16 pour l'entier, 4 et 4 pour les deux registres.
   Voir le README.md pour les détails. *)

(* Puisqu'il n'y a que 8 registres, 3 bits suffisent. Le 4ème était surtout
   là pour avoir 32 bits pour une instruction. Je l'utilise juste pour
   laisser le 0000 quand l'instruction ne mentionne pas de registre. *)
let bin_r = function
  | "r1" -> "1000"
  | "r2" -> "1001"
  | "r3" -> "1010"
  | "r4" -> "1011"
  | "rax" -> "1100"
  | "rbx" -> "1101"
  | "rcx" -> "1110"
  | "rck" -> "1111"
  | _ -> failwith "n'arrive pas, d'après le lexer"

let unsigned15 n =
  let s = ref "" and k = ref n in
  for _ = 1 to 15 do
    s := string_of_int (!k mod 2) ^ !s ;
		k := !k lsr 1 done;
  !s
let bin_e loc n =
  if n>=0 then
    if n>65535 then raise (Prod_error {loc = loc ;
      msg = "L'entier à cette ligne est trop grand pour 16 bits signés, max 65535."})
    else "0" ^ (unsigned15 n)
  else
    if n< -65536 then raise (Prod_error {loc = loc ;
      msg = "L'entier à cette ligne est trop petit pour 16 bits signés, min -65536."})
    else "1" ^ (unsigned15 (65536+n))

let _16 = "0000000000000000"
let _4 = "0000"

(* === Fonction principale === *)
let produit filename dlignes =
  let oc = open_out (filename ^ ".txt") in

  (* On commence par repérer à quelles lignes font référence les labels. *)
  let labels = Hashtbl.create 10 in
  let rec mk_labels i = function [] -> [] 
    | (dl : ligne desc) :: q -> begin match dl.desc with
      | Label lbl -> 
        begin match Hashtbl.find_opt labels lbl with
        | Some _ -> raise (Prod_error {loc = dl.loc ;
          msg = "Ce label est défini deux fois."})
        | None -> Hashtbl.add labels lbl i end ;
        mk_labels i q
      | _ -> dl :: (mk_labels (i+1) q)
    end
  in
  let dinstrs = mk_labels 0 dlignes in
  (* === *)

  (* Les instructions *)
  let mk_instr (dl : ligne desc) = match dl.desc with
    | Label _ -> failwith "Déjà traité."
    (* Catégorie 001: Move et Set *)
    | Move(r1,r2) -> "001"^"0001"^"0" ^ _16 ^ (bin_r r1) ^ (bin_r r2)
    | Set(Const n,r2) -> "001"^"0010"^"0" ^ (bin_e dl.loc n) ^ _4 ^ (bin_r r2)
    | Set(Reg r1,r2) -> "001"^"0010"^"1" ^ _16 ^ (bin_r r1) ^ (bin_r r2)

    (* Catérogie 010: les opérations *)
    | Add(Const n,r2) -> "010"^"0001"^"0" ^ (bin_e dl.loc n) ^ _4 ^ (bin_r r2)
    | Add(Reg r1,r2) -> "010"^"0001"^"1" ^ _16 ^ (bin_r r1) ^ (bin_r r2)
    | Mult(Const n,r2) -> "010"^"0010"^"0" ^ (bin_e dl.loc n) ^ _4 ^ (bin_r r2) 
    | Mult(Reg r1,r2) -> "010"^"0010"^"1" ^ _16 ^ (bin_r r1) ^ (bin_r r2) 
    | Sub(Const n,r2) -> "010"^"0011"^"0" ^ (bin_e dl.loc n) ^ _4 ^ (bin_r r2)
    | Sub(Reg r1,r2) -> "010"^"0011"^"1" ^ _16 ^ (bin_r r1) ^ (bin_r r2)
    | Neg(r1) -> "010"^"0100"^"0" ^ _16 ^ (bin_r r1) ^ _4
    | Not(r1) -> "010"^"0101"^"0" ^ _16 ^ (bin_r r1) ^ _4
    | And(Const n,r2) -> "010"^"0110"^"0" ^ (bin_e dl.loc n) ^ _4 ^ (bin_r r2)
    | And(Reg r1,r2) -> "010"^"0110"^"1" ^ _16 ^ (bin_r r1) ^ (bin_r r2) 
    | Or(Const n,r2) -> "010"^"0111"^"0" ^ (bin_e dl.loc n) ^ _4 ^ (bin_r r2) 
    | Or(Reg r1,r2) -> "010"^"0111"^"1" ^ _16 ^ (bin_r r1) ^ (bin_r r2) 
    | Xor(Const n,r2) -> "010"^"1000"^"0" ^ (bin_e dl.loc n) ^ _4 ^ (bin_r r2) 
    | Xor(Reg r1,r2) -> "010"^"1000"^"1" ^ _16 ^ (bin_r r1) ^ (bin_r r2) 
    | Incrz(Const n,r2) -> "010"^"1001"^"0" ^ (bin_e dl.loc n) ^ _4 ^ (bin_r r2) 
    | Incrz(Reg r1,r2) -> "010"^"1001"^"1" ^ _16 ^ (bin_r r1) ^ (bin_r r2)

    (* Catégorie 011: ROM/RAM *)
    | Load((Some r1,n),r2) -> "011"^"0001"^"1" ^ (bin_e dl.loc n) ^ (bin_r r1) ^ (bin_r r2)
    | Load((None,n),r2) -> "011"^"0001"^"0" ^ (bin_e dl.loc n) ^ _4 ^ (bin_r r2)
    | Save(r1,(Some r2,n)) -> "011"^"0010"^"1" ^ (bin_e dl.loc n) ^ (bin_r r2) ^ (bin_r r1)
    | Save(r1,(None,n)) -> "011"^"0010"^"0" ^ (bin_e dl.loc n) ^ _4 ^ (bin_r r1)
    | Load_rom((Some r1,n),r2) -> "011"^"0011"^"1" ^ (bin_e dl.loc n) ^ (bin_r r1) ^ (bin_r r2)
    | Load_rom((None,n),r2) -> "011"^"0011"^"0" ^ (bin_e dl.loc n) ^ _4 ^ (bin_r r2)

    (* Catégorie 100: les sauts *)
    | Jump(lbl) -> (
      try "100"^"0001"^"0" ^ (bin_e dl.loc (Hashtbl.find labels lbl)) ^ _4 ^ _4
      with _ -> raise (Prod_error {loc = dl.loc ; msg = "Ce label n'existe pas."}) )
    | Jump_nul(lbl) -> (
      try "100"^"0010"^"0" ^ (bin_e dl.loc (Hashtbl.find labels lbl)) ^ _4 ^ _4
      with _ -> raise (Prod_error {loc = dl.loc ; msg = "Ce label n'existe pas."}) )
    | Jump_non_nul(lbl) -> (
      try "100"^"0011"^"0" ^ (bin_e dl.loc (Hashtbl.find labels lbl)) ^ _4 ^ _4
      with _ -> raise (Prod_error {loc = dl.loc ; msg = "Ce label n'existe pas."}) )
    | Jump_neg(lbl) -> (
      try "100"^"0100"^"0" ^ (bin_e dl.loc (Hashtbl.find labels lbl)) ^ _4 ^ _4
      with _ -> raise (Prod_error {loc = dl.loc ; msg = "Ce label n'existe pas."}) )
    | Jump_non_neg(lbl) -> (
      try "100"^"0101"^"0" ^ (bin_e dl.loc (Hashtbl.find labels lbl)) ^ _4 ^ _4
      with _ -> raise (Prod_error {loc = dl.loc ; msg = "Ce label n'existe pas."}) )

    (* Catégorie 101: pour les horloges *)
    | Move_real_clock(r1) -> "101"^"0001"^"0" ^ _16 ^ (bin_r r1) ^ _4
    | Sept_batons(r1,(Some r2,n)) -> "101"^"0010"^"1" ^ (bin_e dl.loc n) ^ (bin_r r2) ^ (bin_r r1)
    | Sept_batons(r1,(None,n)) -> "101"^"0010"^"0" ^ (bin_e dl.loc n) ^ _4 ^ (bin_r r1)
  in
  List.iter (fun dl -> output_string oc (mk_instr dl ^ "\n")) dinstrs ;
  close_out oc
