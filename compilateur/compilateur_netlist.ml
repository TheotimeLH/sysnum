open Netlist_ast
open Format

let print_only = ref false
 

let long_bus p id = try match Env.find id p.p_vars with TBit -> 1| TBitArray n -> n
with Not_found -> (match List.assoc id p.p_eqs with
|Earg (Aconst (VBit i)) -> 1
|Earg (Aconst (VBitArray a)) -> Array.length a
|_ -> print_string id ;raise Exit 
)



let verif p b =
  let nbportes = List.length p.p_inputs + List.length p.p_eqs in
  let nbreg = ref 0 in
  let nbram = ref 0 in
  let liste_reg = ref [] in
  let liste_ram = ref [] in
  let liste_rom = ref [] in
  let comptage (id, expr) =
    if ((id.[0] = '-') && b) then (
      Printf.printf "porte qui commence par le signe - interdite : %s" id;
      failwith ""); 
    if long_bus p id > Sys.int_size 
    then (
      Printf.printf "Bus de taille supérieure à la taille autorisée : %s" id;
      failwith "");
    match expr with
      |Ereg idd -> incr nbreg; liste_reg := id::!liste_reg
      |Eram (adrsize, wsize, a,b,c,d) -> incr nbram; 
        liste_ram := id::!liste_ram
      |Eslice (i,j, f) -> assert (j >= i)
      |Erom (addrsize, wsize, a) -> liste_rom := (id, addrsize, wsize)::!liste_rom
      |_-> ()
  in
  List.iter comptage p.p_eqs;
  (!nbreg, !liste_reg, !nbram, !liste_ram, nbportes, !liste_rom)
  
let print_simu_init fmt ((nbreg, liste_reg, rbram, liste_ram, nbportes, liste_rom), filename) =
  fprintf fmt "
type memoire = {mutable tour : int; data : int array ; ajour : int array}

type fonction = memoire -> int

type ram = {ram_data : int array; ram_addr : int -> int}

type rom = {rom_data : int array; rom_addr : int -> int}

type porte =
  |Const of int
  |Input of string * int
  |UnopNot of fonction
  |BinopOr of fonction * fonction 
  |BinopAnd of fonction * fonction 
  |BinopXor of fonction * fonction 
  |BinopNand of fonction * fonction 
  |Copie of fonction
  |Registre of int
  |Mux of fonction * fonction * fonction
  |Concat of fonction * int * fonction
  |Select of fonction * int
  |Slice of fonction * int * int
  |Ram of fonction * ram
  |Rom of fonction * rom

let nbpas = ref (-1)
let nosilent = ref true
";
fprintf fmt "
let nbreg = %d
let memreg = ref (Array.make nbreg 0)
let nbportes = %d
" nbreg nbportes;
fprintf fmt "

let construit_rom st addr_size w_size =
  let fichier_rom = open_in (\"%s\"^st^\".txt\") in
  try
    let data = Array.make (1 lsl addr_size) 0 in
    for i = 0 to ((1 lsl addr_size) -1) do
    let line = input_line fichier_rom in 
    let ent = int_of_string line in            
    if ent >= (1 lsl w_size) then failwith \"la rom contient un entier trop gros\";
    data.(i) <- ent
    done;
    close_in fichier_rom;
    {rom_data = data; rom_addr = (fun x -> x land ((1 lsl addr_size) - 1))}
    with e ->                     
      close_in_noerr fichier_rom;         
      raise e
" (filename^"_rom_");
fprintf fmt "
let bol c var = ((c var) land 1) <> 0

let calcul_porte var = function
  |Const n -> n
  |Input (s, n) -> begin
    let entree_invalide = ref true in
    let v = ref 0 in
    while !entree_invalide do
      Printf.printf \"valeur de %%s (entier inférieur à %%d)\\n\" s ((1 lsl (n)) - 1);
      v := read_int (); 
      let test = lnot ((1 lsl n) - 1) in
      if !v land test = 0 then entree_invalide := false
      else Printf.printf \"entrée invalide\\n\"
    done;
    !v end
  |UnopNot f -> lnot (f var)
  |BinopOr (f, g) -> (f var) lor (g var)
  |BinopXor (f, g) -> (f var) lxor (g var)
  |BinopAnd (f, g) -> (f var) land (g var)
  |BinopNand (f, g) -> lnot ((f var) land (g var))
  |Copie f -> f var
  |Registre i -> !memreg.(i) 
  |Mux (c, f0, f1) -> if bol c var then f1 var else f0 var
  |Concat (f, n, g) -> let x = g var and y = f var in
    let x = x land ((1 lsl n) - 1) in
    x lor (y lsl n)
  |Select (f, n) -> let x = f var in (x land (1 lsl n)) lsr n
  |Slice (f, dep, long) -> 
      let x = f var in (x lsr dep) land ((1 lsl long) -1)  
  |Ram (f, r) -> let x = r.ram_addr (f var) in r.ram_data.(x)
  |Rom (f, r) -> let x = r.rom_addr (f var) in r.rom_data.(x) 

let memo var n f = 
  if var.ajour.(n) = var.tour then var.data.(n)
  else begin let resultat = calcul_porte var f in
    var.data.(n) <- resultat;
    var.ajour.(n) <- var.tour;
    resultat end

"

let print_sorties fmt p = 
  let print_sortie fmt id =
    fprintf fmt "(\"%s\", %s, %d); " id ("porte" ^ id) (long_bus p id) in
  List.iter (print_sortie fmt) p.p_outputs


let print_reg fmt liste_reg =
  let print_un_reg fmt id = fprintf fmt "%s; " ("majreg" ^ id) in
  List.iter (print_un_reg fmt) liste_reg

let print_ram fmt liste_ram = 
  let print_un_ram fmt id = fprintf fmt "%s; " ("majram" ^ id) in
  List.iter (print_un_ram fmt) liste_ram


let print_simu_fin fmt (resultat, p) = 
  let (nbreg, liste_reg, nbram, liste_ram, nbportes, liste_rom) = resultat in
  fprintf fmt "


let rec exesorties var = function
  |[] -> ()
  |(id, f, size)::t -> if !nosilent then Printf.printf \"%%s : %%d \\n\" id ((f var) land ((1 lsl size) -1)); exesorties var t

let sorties = [%a]
" print_sorties p;
  fprintf fmt "
let rec majreg var liste =
  let newReg = Array.make (List.length liste) 0 in
  List.iter (function f -> f var newReg) liste;
  newReg

let listereg = [%a]
" print_reg liste_reg;
  fprintf fmt "
let rec majram var = function
  |[] -> ()
  |f::t -> f var; majram var t

let listeram = [%a]" print_ram liste_ram;
fprintf fmt "


let main nbpas =
  let var = {tour = 0; data = Array.make nbportes 0;
    ajour = Array.make nbportes (-1)} in
  while var.tour < nbpas do
    if !nosilent then Printf.printf \"-----step %%d-----\\n\" var.tour;
    var.tour <- var.tour + 1;
    exesorties var sorties;
    let newReg = majreg var listereg in
    majram var listeram;
    memreg := newReg 
    done

let ignore str = ()
  
let exec () =
  Arg.parse [(\"-n\", Arg.Set_int nbpas, \"Nombre de tours d’horloge à effectuer\");
  (\"-muet\", Arg.Clear nosilent, \"Ne pas afficher les sorties\")] ignore \"\";
  main !nbpas;;

exec ()
"

let vti = function (*value to int*)
  |VBit true -> 1
  |VBit false -> 0
  |VBitArray tab -> let res = ref 0 and n = Array.length tab -1 in
    for i = 0 to n do
      if tab.(n-i) then res := !res + (1 lsl i) done; !res



let ats = function (*arg to string*)
  |Avar s -> "porte"^s
  |Aconst n -> "(fun x ->" ^ (string_of_int (vti n)) ^")"

let long_const = function
  |VBitArray n -> Array.length n
  |VBit _ -> 1


let print_simu_milieu fmt p =
  let numporte = ref 0 in
  let numreg = ref 0 in
  let print_line fmt id = 
    fprintf fmt "
%s porte%s var = memo var %d " (if !numporte = 0 then "let rec" else "and")
    id !numporte;
    incr numporte in
  let print_entrees fmt id =
    fprintf fmt "%a" print_line id;
    fprintf fmt "(Input (\"%s\", %d))" id (long_bus p id)
  in
  List.iter (print_entrees fmt) p.p_inputs;
  let print_eq fmt (id, expr) =
    let print_expr fmt = function
      |Earg (Avar s) -> fprintf fmt "(Copie (porte%s))" s
      |Earg (Aconst n) -> fprintf fmt "(Const %d)" (vti n)
      |Ereg s -> fprintf fmt "(Registre %d)
and majreg%s var tab = tab.(%d) <- porte%s var"
!numreg id !numreg s; incr numreg
      |Enot s -> fprintf fmt "(UnopNot %s)" (ats s)
      |Ebinop (Or, f, g) -> fprintf fmt "(BinopOr (%s, %s))" (ats f) (ats g)
      |Ebinop (Xor, f, g) -> fprintf fmt "(BinopXor (%s, %s))" (ats f) (ats g)
      |Ebinop (And, f, g) -> fprintf fmt "(BinopAnd (%s, %s))" (ats f) (ats g)
      |Ebinop (Nand, f, g) -> fprintf fmt "(BinopNand (%s, %s))" (ats f) (ats g)
      |Emux (c, f, g) -> fprintf fmt "(Mux (%s, %s, %s))" (ats c) (ats f) (ats g)
      |Erom (i, j, f) -> fprintf fmt "(Rom (%s, rom%s))
and rom%s = construit_rom \"%s\" %d %d" (ats f) id id id i j
      |Eram (i, j, read, we, wa, dat) -> fprintf fmt "(Ram (%s, ram%s))
and ram%s = {ram_data = Array.make %d 0; ram_addr = (fun x -> x land %d)}
and majram%s var = if bol %s var then
  ram%s.ram_data.(ram%s.ram_addr (%s var)) <- %s var" (ats read) id id (1 lsl i) ((1 lsl i) - 1) id (ats we) id id (ats wa) (ats dat)
      |Econcat (g, Avar idd) -> fprintf fmt "(Concat (%s, %d, porte%s))" (ats g) (long_bus p idd) idd
      |Econcat (g, Aconst n) -> fprintf fmt "(Concat (%s, %d, %s)" (ats (Aconst n)) (match n with VBit _ -> 1| VBitArray n -> Array.length n) (ats g)
      |Eslice (i, j, Avar idd) -> fprintf fmt "(Slice (porte%s, %d, %d))" (idd) ((long_bus p idd) - j - 1) (j- i + 1)
      |Eslice (i, j, Aconst n) -> fprintf fmt "(Slice (%s, %d, %d))" (ats (Aconst n)) ((long_const n) - i - 1) (j- i + 1)
      |Eselect (i, Avar idd) -> 
          fprintf fmt "(Select (porte%s, %d))" (idd) ((long_bus p idd) - i - 1)
      |Eselect (i, Aconst n) ->
          fprintf fmt "(Select (%s, %d))" (ats (Aconst n)) ((long_const n) - i -1)
    in
    fprintf fmt "%a" print_line id;
    fprintf fmt "%a" print_expr expr;
  in
  List.iter (print_eq fmt) p.p_eqs

let compilation filename resultat p = 
  assert (filename.[0] <> '*');
  let target = filename ^ "_simu.ml" in
  let ch = open_out target in
  let fmt =Format.formatter_of_out_channel ch in
  fprintf fmt "@[
%a
" print_simu_init (resultat, filename);
  fprintf fmt "%a" print_simu_milieu p;
  fprintf fmt "%a@]@." print_simu_fin (resultat,  p);
  close_out ch;

  Printf.printf "Le fichier %s a été créé\n" target
 

let crearom resultat filename = 
  let construit_rom (st, addr_size, w_size) =
    let targrom = filename ^ "_rom_" ^ st ^ ".txt" in
    let ch = open_out targrom in
    let fmt = Format.formatter_of_out_channel ch in
    fprintf fmt "@[";
    for i = 0 to ((1 lsl addr_size) -1) do
      fprintf fmt "0\n";
    done;
    fprintf fmt "@]@.";
    close_out ch;
    Printf.printf "Le fichier rom %s a été réinitialisée\n" targrom in
 let (_,_,_,_,_,liste_rom) = resultat in
 List.iter construit_rom liste_rom

let compile filename =
  try
    let sourcename = filename ^ ".net" in
    let p = Netlist.read_file sourcename in
    begin try
        let () = Scheduler.donne_diam p in
        let resultat = verif p true in
        compilation filename resultat p;
        crearom resultat filename;
      with
        | Scheduler.Combinational_cycle ->
            Format.eprintf "The netlist has a combinatory cycle.@.";
            failwith " "
    end;
  with
    | Netlist.Parse_error s -> Format.eprintf "An error accurred: %s@." s; exit 2

let main () =
  Arg.parse []
    compile ""
;;

main ()
