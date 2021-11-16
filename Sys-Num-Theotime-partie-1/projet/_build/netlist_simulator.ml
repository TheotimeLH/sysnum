open Netlist_ast

(* ========== Paramètres ========== *)

let print_only = ref false
let number_steps = ref (-1)
let print_sorties = ref true
let dossier_rom = ref "rom_test"

(* ========== Fonctions auxiliaires ========== *)

(* ==== Pour initialiser ==== *)
let size_to_bus s =
  if s = 1 then VBit false else VBitArray (Array.make s false) 

let ty_to_bus = function
  |TBit -> VBit false
  |TBitArray n -> VBitArray (Array.make n false)


(* ==== Pour passer des int aux bool array ==== *)

type str_bits = string 
(*chaine de caractères où est écrit un int en binaire, exemple : "0010"
	En lecture, si on attend n bits et qu'on en reçoit moins, les bits de 
	poids forts sont 0 par défaut. Si on en reçoit trop on ignore les bits 
	de poids trop forts, exemple : si on veut 4 bits "010100" -> "0100"
	Rem : tout chiffre > 0 est pris pour un 1, exemple : "0502" -> "0101" *)

let str_bits_to_value s k = (* k : le nb de bits voulus *)
	let n = String.length s in
	if k = 1 then VBit (int_of_char s.[n-1] >48) (* int_of_char '0' = 48 *)
	else begin
		let t = Array.make n false in
		for i = 1 to min n k do
			t.(k-i) <- int_of_char s.[n-i] > 48 done ;
		VBitArray t 
		end

let value_to_str_bits =
	let f = fun b -> if b then "1" else "0" in
	function
	|	VBit b -> f b
	|	VBitArray t -> String.concat "" (List.map f (Array.to_list t)) 

let value_to_int v = int_of_string (value_to_str_bits v)


(* ==== Utile pour simuler ==== *)

let arg_to_value t = function
  | Avar id -> Hashtbl.find t id
  | Aconst v -> v

let arg_to_int t a = value_to_int (arg_to_value t a)

let arg_to_bool tb a = match arg_to_value tb a with
  |VBit b -> b
  |_ -> failwith "if with a bus"

let vbit_to_array = function
  |VBit b -> [|b|]
  |VBitArray t -> t

let fait_binop op b1 b2 = match op with
  |Or -> b1 || b2   |Xor -> b1 <> b2
  |And -> b1 && b2  |Nand -> not (b1 && b2)


(* ==== Inputs ==== *)

let fait_input program tb_val = 
	let lit id = 
		Printf.printf "%s = " id ;
		Hashtbl.replace tb_val id 
			begin str_bits_to_value (read_line ()) 
				(match Env.find id program.p_vars with 
					|	TBit -> 1 	| TBitArray n -> n ) end
		in
	List.iter lit program.p_inputs


(* ==== Pour récupérer les ROM ==== *)

let cree_rom t_roms (id,a_size,w_size) =
	let lit_rom ic_rom =
		let m = 1 lsl a_size in
		let rom = Array.make m (size_to_bus w_size) in
		let k = ref 0 in 
		let end_of_file = ref false in
		while !k < m && not !end_of_file do
			incr k ;
			try 
				rom.(!k-1) <- str_bits_to_value (input_line ic_rom) w_size
			with
				|End_of_file -> end_of_file := true ; 
					print_endline "Attention, il manque des données, 0 par défaut"
				|Failure _ -> 
					print_endline "Attention, il a des caractères dans le fichier"
			done;
		Hashtbl.add t_roms id rom in
	
	try
		lit_rom (open_in (!dossier_rom ^ "/" ^ id ^ ".txt"))
	with
		Sys_error _ -> 
			Printf.printf "Quelle est la ROM pour %s ? (on demande un .txt) \n" id ; 
			Printf.printf "(NB: Avec l'argument -rom vous pouvez indiquer un
dossier où chercher, par défaut actuellement %s) \n" !dossier_rom ; 
			try lit_rom (open_in (read_line ()))
			with 
				Sys_error _ -> 
					print_endline "Fichier non trouvé, ROM initialisée avec des 0" ;
					Hashtbl.add t_roms id (Array.make (1 lsl a_size) (size_to_bus w_size))


(* ============================================= *)


let simulator program number_steps =
	let list_rom = ref [] in let list_ram = ref [] in 
	let list_reg = ref [] in (*pour initialiser *)	
	let l_ram = ref [] in
	let pour_init = function
		|(_,Ereg x) -> list_reg := x :: !list_reg
		|(x,Erom(a_size,w_size,_)) ->
			list_rom := (x,a_size,w_size) :: !list_rom
		|(x,Eram(a_size,w_size,_,we,wa,data)) ->
            list_ram := (x,a_size,w_size) :: !list_ram ;
			l_ram := (x,we,wa,data) :: !l_ram
		|_ -> () in
	List.iter pour_init program.p_eqs ;
	(* Initialisation des registres *)
	let tb_reg = Hashtbl.create (List.length !list_reg) in
	List.iter (fun id -> 
		Hashtbl.add tb_reg id (ty_to_bus (Env.find id program.p_vars))) !list_reg ;
	(* Initialisation des ROM / RAM *)
	let tb_rom = Hashtbl.create (List.length !list_rom) in
	let tb_ram = Hashtbl.create (List.length !list_ram) in
	let cree_ram (id,a_size,w_size) =
		Hashtbl.add tb_ram id (Array.make (1 lsl a_size) (size_to_bus w_size)) in
	List.iter cree_ram !list_ram ;
	List.iter (cree_rom tb_rom) !list_rom ;
		
	let tb_val = Hashtbl.create 40 in
	
	let step = ref 0 in
	while number_steps - !step <> 0 do
		incr step ;
		if !print_sorties then Printf.printf "Step %d \n" !step;
		(* INPUTS *)
		fait_input program tb_val ;
		(* EQUATIONS *) 
		let applq_eqs (id,exp) =
			Hashtbl.replace tb_val id begin match exp with	
				|Earg a -> arg_to_value tb_val a
				|Ereg r -> Hashtbl.find tb_reg r
				|Enot a -> 
					begin match arg_to_value tb_val a with
						|VBit b -> VBit (not b)
						|VBitArray t -> VBitArray (Array.map not t) 
					end
				|Ebinop (op,a1,a2) ->
					begin match arg_to_value tb_val a1 , arg_to_value tb_val a2 with
						|VBit b1, VBit b2 -> VBit (fait_binop op b1 b2)
						|VBitArray t1, VBitArray t2 -> 
							VBitArray (Array.map2 (fait_binop op) t1 t2)
						|_,_ -> failwith "op of buses with diff length"
					end
				|Emux (choice,a1,a2) ->
					if arg_to_bool tb_val choice
						then arg_to_value tb_val a2
					else arg_to_value tb_val a1
				|Erom (_,_,a) -> (Hashtbl.find tb_rom id).(arg_to_int tb_val a)
				|Eram (_,_,r_addr,_,_,_) -> 
					(Hashtbl.find tb_ram id).(arg_to_int tb_val r_addr) 
				|Econcat (a1,a2) ->
					let t1 = vbit_to_array (arg_to_value tb_val a1) in
					let t2 = vbit_to_array (arg_to_value tb_val a2) in
					VBitArray (Array.concat [t1;t2])
				|Eselect (i,a) ->
					begin match arg_to_value tb_val a with
						|VBit b -> if i=0 then VBit b 
								else failwith "i-th value with i>len"
						|VBitArray t -> VBit t.(i)
					end
				|Eslice (i1,i2,a) ->
					begin match arg_to_value tb_val a with
						|VBit _ -> failwith "slice of VBit"
						|VBitArray t -> VBitArray (Array.sub t i1 (i2-i1+1))
					end
			end
		in
		List.iter applq_eqs program.p_eqs ;
		(* REGISTERS *)
		List.iter (fun id -> 
			Hashtbl.replace tb_reg id (Hashtbl.find tb_val id)) !list_reg ;
		(* RAM *)
		let modif_ram (id,we,wa,data) =  
			if arg_to_bool tb_val we
      	then (Hashtbl.find tb_ram id).(arg_to_int tb_val wa) 
						<- arg_to_value tb_val data in
		List.iter modif_ram !l_ram ;
		(* SORTIE *)
		let affiche id = Printf.printf "=> %s = %s \n" 
			 id (value_to_str_bits (Hashtbl.find tb_val id)) in
		if !print_sorties then List.iter affiche program.p_outputs ;
 
		done



let compile filename =
  try
    let p = Netlist.read_file filename in
    begin try
        let p = Scheduler.schedule p in
        simulator p !number_steps
      with
        | Scheduler.Combinational_cycle ->
            Format.eprintf "The netlist has a combinatory cycle.@.";
    end;
  with
    | Netlist.Parse_error s -> Format.eprintf "An error accurred: %s@." s; exit 2

let main () =
  Arg.parse
    ["-n", Arg.Set_int number_steps, "Number of steps to simulate";
		 "-s", Arg.Clear print_sorties, "Disable print outputs";
		 "-rom", Arg.Set_string dossier_rom, "Roms' directory"]
    compile
    ""
;;

main ()
